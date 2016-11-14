#!/bin/sh

set -e

cmd="$@"

until psql -h "$POSTGRES_SERVICE_HOST" -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing $cmd"
exec $cmd
