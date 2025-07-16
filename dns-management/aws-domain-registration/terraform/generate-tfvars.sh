#!/bin/bash
set -e

# Load environment variables from .env file
if [ -f "../../../../.env" ]; then
  source "../../../../.env"
else
  echo "Error: .env file not found"
  exit 1
fi

# Replace environment variables in the terraform.tfvars.template file
envsubst < terraform.tfvars.template > terraform.tfvars

echo "Generated terraform.tfvars file with values from .env"