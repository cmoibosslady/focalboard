#!/bin/sh
set -eu

DATA_DIR="/var/lib/postgresql/data"
. /run/secrets/db_credentials

export POSTGRES_PASSWORD POSTGRES_NAME POSTGRES_USER

if [ -z "$POSTGRES_PASSWORD" ]; then
	echo "Error: DB password is empty. Set POSTGRES_PASSWORD in /run/secrets/db_credentials."
	exit 1
fi

mkdir -p "$DATA_DIR" /run/postgresql
chown -R postgres:postgres /var/lib/postgresql /run/postgresql
chmod 700 "$DATA_DIR"

if [ ! -s "$DATA_DIR/PG_VERSION" ]; then
	echo "Initializing PostgreSQL data directory..."
	su postgres -c "initdb -D '$DATA_DIR'"

	echo "Starting temporary PostgreSQL for bootstrap..."
	su postgres -c "pg_ctl -D '$DATA_DIR' -o \"-c listen_addresses='*'\" -w start"

	echo "Creating role/database from secret..."
	envsubst < /initdb.sql | su postgres -c "psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres"
	echo "Stopping temporary PostgreSQL..."
	su postgres -c "pg_ctl -D '$DATA_DIR' -m fast -w stop"
fi

if [ -f "$DATA_DIR/pg_hba.conf" ]; then
	if ! grep -q "^host[[:space:]]\+all[[:space:]]\+all[[:space:]]\+0\.0\.0\.0/0[[:space:]]\+scram-sha-256" "$DATA_DIR/pg_hba.conf"; then
		echo "host all all 0.0.0.0/0 scram-sha-256" >> "$DATA_DIR/pg_hba.conf"
	fi
	if ! grep -q "^host[[:space:]]\+all[[:space:]]\+all[[:space:]]\+::/0[[:space:]]\+scram-sha-256" "$DATA_DIR/pg_hba.conf"; then
		echo "host all all ::/0 scram-sha-256" >> "$DATA_DIR/pg_hba.conf"
	fi
fi

echo "Starting PostgreSQL..."
exec su postgres -c "postgres -D '$DATA_DIR' -c listen_addresses='*'"
