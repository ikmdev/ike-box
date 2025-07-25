#!/bin/sh
set -x

if ! echo "$BASE_DOMAIN" | grep -Eq '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$'; then
  echo "Error: BASE_DOMAIN must be a valid domain (e.g., example.com, example.org, sub.example.co.uk)"
  exit 1
fi

while :; do
  echo "BASE DOMAIN: ${BASE_DOMAIN}"
  certbot certonly --email devops@ikm.dev --agree-tos --no-eff-email \
    -d "${BASE_DOMAIN}" -d "*.${BASE_DOMAIN}" --non-interactive --keep-until-expiring --manual
  certbot renew --webroot --webroot-path=/var/www/certbot --non-interactive
  sleep 12h & wait $!
done
echo "Certbot entrypoint script completed."
