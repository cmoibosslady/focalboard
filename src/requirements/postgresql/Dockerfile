FROM alpine:3.21.5

RUN <<EOF
apk update
apk add --no-cache \
	postgresql \
	postgresql-contrib \
	envsubst \
	bash
EOF

RUN mkdir -p /var/lib/postgresql/data /run/postgresql \
	&& chown -R postgres:postgres /var/lib/postgresql /run/postgresql

COPY ./initdb.sh /usr/local/bin/postgres-entrypoint.sh
COPY ./initdb.sql /initdb.sql

RUN chmod +x /usr/local/bin/postgres-entrypoint.sh

EXPOSE 5432

ENTRYPOINT ["/usr/local/bin/postgres-entrypoint.sh"]
