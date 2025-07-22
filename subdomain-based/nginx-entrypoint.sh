#!/bin/sh
set -ex

ENV_FILE="/.env"

# Source .env file if it exists
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=src/util.sh
  . "$ENV_FILE"
  set +a
else
  echo ".env file not found at $ENV_FILE"
fi

# Replace environment variables in the Nginx configuration templates
envsubst '${BASE_DOMAIN} ${WWW_SUBDOMAIN} ${NEXUS_SUBDOMAIN} ${KOMET_SUBDOMAIN}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx
exec nginx -g 'daemon off;'