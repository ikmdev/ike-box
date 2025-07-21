FROM nginx:1.26.3

# Install OpenSSL for certificate generation
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Copy files
COPY html/* /usr/share/nginx/html/
COPY subdomain-based/nginx.conf.template /etc/nginx/nginx.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /docker-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]