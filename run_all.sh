#!/usr/bin/env bash
# Builds the database from scratch and saves every query result to results/.
#
#   docker compose up -d        (or use any Postgres 13+ you already have)
#   ./get_data.sh
#   ./run_all.sh
#
# Connection comes from the usual PG env vars. Defaults match docker-compose.yml.
set -e
export PGHOST=${PGHOST:-localhost}
export PGPORT=${PGPORT:-5432}
export PGUSER=${PGUSER:-postgres}
export PGPASSWORD=${PGPASSWORD:-postgres}
DB=${PGDATABASE:-olist}

psql -d postgres -qtc "SELECT 1 FROM pg_database WHERE datname = '$DB'" | grep -q 1 \
  || psql -d postgres -qc "CREATE DATABASE $DB"

echo "schema + load"
psql -d "$DB" -q -v ON_ERROR_STOP=1 -f sql/00_schema.sql
psql -d "$DB" -q -v ON_ERROR_STOP=1 -f sql/01_load.sql
psql -d "$DB" -q -v ON_ERROR_STOP=1 -f sql/02_views.sql

mkdir -p results
for f in sql/[1-9]*.sql; do
  name=$(basename "$f" .sql)
  echo "  $name"
  # strip the SET line so the CSV only has the result set
  psql -d "$DB" -q -v ON_ERROR_STOP=1 --csv -c "SET search_path TO olist;" -f "$f" \
    | sed '/^SET$/d' > "results/$name.csv"
done
echo "results written to results/"
