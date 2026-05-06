#!/bin/sh
set -e

SECRETS_FILE="/run/secrets/db_credentials"

if [ -f "$SECRETS_FILE" ]; then
  set -a
  . "$SECRETS_FILE"
  set +a
fi

if [ -z "$DBCONFIG" ]; then
  : "${POSTGRES_USER:?Missing POSTGRES_USER}"
  : "${POSTGRES_PASSWORD:?Missing POSTGRES_PASSWORD}"
  : "${POSTGRES_NAME:?Missing POSTGRES_NAME}"
  DBCONFIG="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgresql:5432/${POSTGRES_NAME}?sslmode=disable&connect_timeout=10"
  export DBCONFIG
fi

envsubst < /opt/focalboard/config.template.json > /opt/focalboard/config.json

exec "$@"
