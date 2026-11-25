#!/usr/bin/env bash
# Local development only, see dev/compose.fast.yml: what /docker-entrypoint.sh zammad-init does, in one
# Rails boot instead of five. Without Elasticsearch (es_url stays empty) and addon packages, which a local
# Backoffice doesn't use.
set -euo pipefail
export PGPASSWORD="$POSTGRESQL_PASS"
psql=(psql -h "$POSTGRESQL_HOST" -p "$POSTGRESQL_PORT" -U "$POSTGRESQL_USER" -d "$POSTGRESQL_DB" -tAc)

until pg_isready -q -h "$POSTGRESQL_HOST" -p "$POSTGRESQL_PORT"; do sleep 0.5; done

# the entrypoint asks Rails (User.any?), a Rails boot of its own
if [ "$("${psql[@]}" "SELECT to_regclass('public.users') IS NOT NULL" 2>/dev/null)" = t ] &&
   [ "$("${psql[@]}" "SELECT EXISTS (SELECT 1 FROM users)")" = t ]; then
  exec bundle exec rails r /opt/ops-dev/init.rb
else
  echo "Installing Zammad..."
  exec bundle exec rake db:create db:migrate db:seed
fi
