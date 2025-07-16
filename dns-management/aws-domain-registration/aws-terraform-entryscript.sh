#!/bin/sh

set -x

ENV_FILE="/.env"

# Source .env file if it exists
if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
else
  echo ".env file not found at $ENV_FILE"
fi

if ! echo "$BASE_DOMAIN" | grep -Eq '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$'; then
  echo "Error: BASE_DOMAIN must be a valid domain (e.g., example.com, example.org, sub.example.co.uk)"
  exit 1
fi

# Substitute variables in terraform.tfvars.template and output to terraform.tfvars
TEMPLATE_FILE="$SCRIPT_DIR/terraform.tfvars.template"
OUTPUT_FILE="$SCRIPT_DIR/terraform.tfvars"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file not found: $TEMPLATE_FILE"
  exit 1
fi

# Replace variables in the template (assumes ${VAR} syntax)
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
echo "Generated $OUTPUT_FILE from $TEMPLATE_FILE using .env variables."

