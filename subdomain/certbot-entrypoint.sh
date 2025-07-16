#!/bin/sh
set -x

while :; do
echo "ALL DOMAINS: $DOMAINS"
  for domain in $(echo "$DOMAINS" | tr ',' ' '); do
    echo "DOMAIN: $domain"
    certbot certonly --webroot --webroot-path=/var/www/certbot \
      --email devops@ikm.dev --agree-tos --no-eff-email \
      -d "$domain" --non-interactive --keep-until-expiring
  done
  certbot renew --webroot --webroot-path=/var/www/certbot --non-interactive
  sleep 12h & wait $!
done