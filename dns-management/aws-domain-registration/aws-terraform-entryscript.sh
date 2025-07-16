#!/bin/sh

set -x
if ! echo "$BASE_DOMAIN" | grep -Eq '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$'; then
  echo "Error: BASE_DOMAIN must be a valid domain (e.g., example.com, example.org, sub.example.co.uk)"
  exit 1
fi

