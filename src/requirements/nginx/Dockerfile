FROM alpine:3.21.5

RUN <<EOF
apk update && apk upgrade
apk add --no-cache \
	nginx \
	openssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/nginx.key \
	-out /etc/ssl/nginx.crt \
	-subj "/C=FR/ST=/L=Paris/O=42paris/CN=nginx"
EOF

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx"]
