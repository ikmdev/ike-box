FROM nginx:1.26.3

# Install OpenSSL for certificate generation and envsubst for template processing
RUN apt-get update && apt-get install -y openssl gettext-base && rm -rf /var/lib/apt/lists/*

# Copy files
COPY html/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
