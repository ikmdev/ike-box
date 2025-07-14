#!/bin/sh
set -e

# Create directory for certbot webroot challenge
mkdir -p /var/www/certbot

# Read domains from environment variable, default to "localhost" if not set
DOMAINS=${DOMAINS:-localhost}

for DOMAIN in $DOMAINS; do

# Check if certbot certificates exist, if not, generate self-signed certificates
if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ] || [ ! -f /etc/letsencrypt/live/$DOMAIN/privkey.pem ]; then
    echo "Certbot certificates not found, generating self-signed certificates..."
    
    # Create directory structure
    mkdir -p /etc/letsencrypt/live/$DOMAIN
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/letsencrypt/live/$DOMAIN/privkey.pem \
        -out /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
        -subj "/CN=$DOMAIN" \
        -addext "subjectAltName=DNS:$DOMAIN"
    
    echo "Self-signed certificates generated."
fi
done

# Start nginx
exec nginx -g "daemon off;"