#!/bin/bash
set -e

# Replace environment variables in the Nginx configuration templates
envsubst '${BASE_DOMAIN} ${WWW_SUBDOMAIN} ${NEXUS_SUBDOMAIN} ${KOMET_SUBDOMAIN} ${IKMDEV_SUBDOMAIN}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx
exec nginx -g 'daemon off;'