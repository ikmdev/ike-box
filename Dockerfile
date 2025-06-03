FROM nginx:1.26.3
COPY html/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
