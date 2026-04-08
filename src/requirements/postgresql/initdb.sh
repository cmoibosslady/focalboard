#!bin/sh
postgres
psql -U postgres -c "CREATE DATABASE boards; CREATE USER ${DB_USER} WITH ENCRYPTED PASSWORD ${DB_PASSWORD};"
