FROM python:3.9-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir requests

# Copy scripts and configuration files
COPY create_domains.py delete_domains.py /app/
COPY config.json domains.txt /app/

# Make scripts executable
RUN chmod +x /app/create_domains.py /app/delete_domains.py

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create entrypoint script
RUN echo '#!/bin/sh\n\
if [ "$1" = "create" ]; then\n\
    shift\n\
    exec python /app/create_domains.py "$@"\n\
elif [ "$1" = "delete" ]; then\n\
    shift\n\
    exec python /app/delete_domains.py "$@"\n\
else\n\
    echo "Usage: docker run [options] <image> [create|delete] [--config CONFIG_FILE] [--domains DOMAINS_FILE] [SUBDOMAIN...]"\n\
    echo "Examples:"\n\
    echo "  docker run [options] <image> create                    # Create all domains/subdomains"\n\
    echo "  docker run [options] <image> create dev test staging   # Create only dev, test, and staging subdomains"\n\
    echo "  docker run [options] <image> delete                    # Delete all subdomains"\n\
    echo "  docker run [options] <image> delete dev test staging   # Delete only dev, test, and staging subdomains"\n\
    exit 1\n\
fi' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]