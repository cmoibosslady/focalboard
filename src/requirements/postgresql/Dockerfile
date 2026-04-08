FROM alpine:3.21.5

RUN <<EOF
apk update
apk add --no-cache \
	postgresql \
	postgresql-contrib \
	bash
EOF

COPY ./initdb.sh /docker-entrypoint-initdb.d/

EXPOSE 5432

ENTRYPOINT ["bash", "/docker-entrypoint-initdb.d/initdb.sh"]
