#!/bin/sh

set -e

# Create directory for certbot webroot challenge
mkdir -p /var/www/certbot

# Read CERTBOT_HOST from environment variable, default to "localhost" if not set
CERTBOT_HOST=${CERTBOT_HOST:-localhost}

for CERTBOT_HOST in $CERTBOT_HOST; do
  CERT_PATH="/etc/letsencrypt/live/$CERTBOT_HOST"
  FULLCHAIN="$CERT_PATH/fullchain.pem"
  PRIVKEY="$CERT_PATH/privkey.pem"

  export CERT_PATH ${CERT_PATH:-//etc/letsencrypt/live/*.ikedesigns.com}
  envsubst '$CERT_PATH' < ./subdomain/nginx.conf  > /etc/nginx/nginx.conf


  if [ ! -f "$FULLCHAIN" ] || [ ! -f "$PRIVKEY" ]; then
    echo "Certificates for $CERTBOT_HOST not found, generating self-signed certificates..."

    mkdir -p "$CERT_PATH"

    # Generate self-signed certificate for the domain
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout "$PRIVKEY" \
      -out "$FULLCHAIN" \
      -subj "/CN=$CERTBOT_HOST" \
      -addext "subjectAltName=DNS:$CERTBOT_HOST"

    echo "Self-signed certificates generated for $CERTBOT_HOST."
  fi
done

# Start nginx
exec nginx -g "daemon off;"