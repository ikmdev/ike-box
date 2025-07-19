#!/bin/sh

set -x
ENV_FILE="/.env"

# Ensure required tools are installed
REQUIRED_TOOLS="envsubst tofu"
for tool in $REQUIRED_TOOLS; do
  if ! command -v $tool >/dev/null 2>&1; then
    echo "Error: $tool is not installed. Installing..."
    sudo apt-get update && sudo apt-get install -y gettext-base terraform || {
      echo "Failed to install $tool. Exiting."
      exit 1
    }
  fi
done

# Source .env file if it exists
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=src/util.sh
  . "$ENV_FILE"
  set +a
else
  echo ".env file not found at $ENV_FILE"
fi


# Validate BASE_DOMAIN
if ! echo "$BASE_DOMAIN" | grep -Eq '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$'; then
  echo "Error: BASE_DOMAIN must be a valid domain (e.g., example.com, example.org, sub.example.co.uk)"
  exit 1
fi


# Validate ADMIN_PHONE format
if ! echo "$ADMIN_PHONE" | grep -Eq '^\+[0-9]{1,3}\.[0-9]{1,14}$'; then
  echo "Error: ADMIN_PHONE must be in the format +999.12345678"
  exit 1
fi

# Universal zip code format validation
if ! echo "$ADMIN_ZIP" | grep -Eq '^[A-Za-z0-9 \-]+$'; then
  echo "Error: ADMIN_ZIP must be a valid postal code (letters, numbers, spaces, dashes only)"
  exit 1
fi

import_resource() {
  # Runs a tofu import command for a given resource and handles errors.
  # Arguments:
  #   $1 - The tofu import command to execute (as a string)
  #   $2 - A human-readable name for the resource being imported
  # Behavior:
  #   - If the resource already exists, continues execution.
  #   - If the import fails for any other reason, exits the script.
  #   - If the import succeeds, continues execution.
  IMPORT_CMD="$1"
  RESOURCE_NAME="$2"
  IMPORT_OUTPUT=$(eval "$IMPORT_CMD" 2>&1)
  if echo "$IMPORT_OUTPUT" | grep -qi "already exists"; then
    echo "$RESOURCE_NAME already exists, continuing..."
  elif echo "$IMPORT_OUTPUT" | grep -qi "Error"; then
    echo "$RESOURCE_NAME import failed: $IMPORT_OUTPUT"
    exit 1
  else
    echo "$RESOURCE_NAME import succeeded."
  fi
}


# --- Apply backend first ---
BACKEND_TEMPLATE="/aws-backend/terraform.tfvars.template"
BACKEND_VARS="/aws-backend/terraform.tfvars"

if [ ! -f "$BACKEND_TEMPLATE" ]; then
  echo "Backend template file not found: $BACKEND_TEMPLATE"
  exit 1
fi
envsubst < "$BACKEND_TEMPLATE" > "$BACKEND_VARS"
echo "Generated $BACKEND_VARS from $BACKEND_TEMPLATE using .env variables."
cat $BACKEND_VARS


cd /aws-backend || { echo "Failed to change directory to /aws-backend"; exit 1; }
tofu init || { echo "Tofu backend init failed"; exit 1; }

# Import backend resources before apply
import_resource "tofu import aws_s3_bucket.tfstate \"tfstate-${BASE_DOMAIN}\"" "S3 Bucket"
import_resource "tofu import aws_dynamodb_table.tfstate_lock \"${BASE_DOMAIN}-terraform-lock\"" "DynamoDB Table"

# Apply backend, fail on any error except 'already exists'
BACKEND_OUTPUT=$(tofu apply -auto-approve -refresh=false 2>&1)
if echo "$BACKEND_OUTPUT" | grep -qi "already exists"; then
  echo "Some backend resources already exist, continuing..."
elif echo "$BACKEND_OUTPUT" | grep -qi "Error"; then
  echo "Tofu backend apply failed"
  exit 1
fi


# --- Then apply infra ---
TEMPLATE_FILE="/aws-infra/terraform.tfvars.template"
OUTPUT_FILE="/aws-infra/terraform.tfvars"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file not found: $TEMPLATE_FILE"
  exit 1
fi
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
echo "Generated $OUTPUT_FILE from $TEMPLATE_FILE using .env variables."
cat $OUTPUT_FILE

cd /aws-infra || { echo "Failed to change directory to /aws-infra"; exit 1; }
tofu init \
    --backend-config="region=${AWS_REGION}" \
    --backend-config="bucket=tfstate-${BASE_DOMAIN}" \
    --backend-config="key=${BASE_DOMAIN}-dnshosting.tfstate" \
    --backend-config="dynamodb_table=${BASE_DOMAIN}-terraform-lock" \
    || { echo "Tofu infra initialization failed"; exit 1; }


# Import existing domains and A records before apply
echo "Importing existing domains and A records..."

import_resource "tofu import aws_route53domains_domain.main \"${BASE_DOMAIN}\"" "Domain"
import_resource "tofu import aws_route53_record.subdomains[\"www\"] \"${WWW_SUBDOMAIN}\"" "WWW A record"
import_resource "tofu import aws_route53_record.subdomains[\"nexus\"] \"${NEXUS_SUBDOMAIN}\"" "NEXUS A record"
import_resource "tofu import aws_route53_record.subdomains[\"komet\"] \"${KOMET_SUBDOMAIN}\"" "KOMET A record"

tofu plan || { echo "Tofu infra plan failed"; exit 1; }

# Apply infra, ignore errors for already existing resources
tofu apply -auto-approve -refresh=false || {
  if grep -q "already exists" tofu.log; then
    echo "Some resources already exist, continuing..."
  else
    echo "Tofu infra apply failed"; exit 1;
  fi
}

