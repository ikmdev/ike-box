#!/bin/sh
set -e

# Create directory for certbot webroot challenge
mkdir -p /var/www/certbot

for domain in $

# Check if certbot certificates exist, if not, generate self-signed certificates
# if [ ! -f /etc/letsencrypt/live/localhost/fullchain.pem ] || [ ! -f /etc/letsencrypt/live/localhost/privkey.pem ]; then
#     echo "Certbot certificates not found, generating self-signed certificates..."
    
#     # Create directory structure
#     mkdir -p /etc/letsencrypt/live/localhost
    
#     # Generate self-signed certificate
#     openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#         -keyout /etc/letsencrypt/live/localhost/privkey.pem \
#         -out /etc/letsencrypt/live/localhost/fullchain.pem \
#         -subj "/CN=localhost" \
#         -addext "subjectAltName=DNS:localhost"
    
#     echo "Self-signed certificates generated."
# fi

# Start nginx
exec nginx -g "daemon off;"