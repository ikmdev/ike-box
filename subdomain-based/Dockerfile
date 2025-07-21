FROM nginx:1.26.3

# Install OpenSSL for certificate generation and envsubst for template processing
RUN apt-get update && apt-get install -y openssl gettext-base && rm -rf /var/lib/apt/lists/*

# Copy files
COPY subdomain-based/nginx.conf.template /etc/nginx/nginx.conf.template
COPY subdomain-based/nginx-entrypoint.sh /docker-entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /docker-nginx-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
