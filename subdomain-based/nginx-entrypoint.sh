#!/bin/bash
set -e

# Load and expand .env variables if present
if [ -f "/.env" ]; then
  set -a
  . "/.env"
  set +a
  # Re-export with expansion
  export WWW_SUBDOMAIN="www.${BASE_DOMAIN}"
  export NEXUS_SUBDOMAIN="nexus.${BASE_DOMAIN}"
  export KOMET_SUBDOMAIN="komet.${BASE_DOMAIN}"
fi

# Replace environment variables in the Nginx configuration templates
envsubst '${BASE_DOMAIN} ${WWW_SUBDOMAIN} ${NEXUS_SUBDOMAIN} ${KOMET_SUBDOMAIN}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx
exec nginx -g 'daemon off;'


