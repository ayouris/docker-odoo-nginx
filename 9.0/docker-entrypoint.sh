#!/bin/sh

set -e

echo "${NGX_HTTP_ACCESS}" > /etc/nginx/http-access.conf
echo "${NGX_HTPASSWD}" > /etc/nginx/htpasswd

/usr/local/bin/confd -onetime -backend env

# Wait for the Odoo app to be reachable before starting nginx.
# This mirrors what the Odoo image does with the database: nginx cannot
# resolve the upstream host until the app container is registered in
# Docker's internal DNS, so we block here until the app port is open.
ODOO_HOST="${NGX_ODOO_HOST:-odoo}"
ODOO_PORT="${NGX_ODOO_PORT:-8069}"
WAIT_TIMEOUT="${NGX_ODOO_WAIT_TIMEOUT:-300}"

echo "Waiting for Odoo app at ${ODOO_HOST}:${ODOO_PORT} (timeout ${WAIT_TIMEOUT}s)..."
elapsed=0
while ! nc -z "${ODOO_HOST}" "${ODOO_PORT}" 2>/dev/null; do
  if [ "${elapsed}" -ge "${WAIT_TIMEOUT}" ]; then
    echo "ERROR: Odoo app not reachable at ${ODOO_HOST}:${ODOO_PORT} after ${WAIT_TIMEOUT}s. Giving up." >&2
    exit 1
  fi
  echo "Odoo app not ready yet (${elapsed}s elapsed). Retrying in 5s..."
  sleep 5
  elapsed=$((elapsed + 5))
done
echo "Odoo app is reachable at ${ODOO_HOST}:${ODOO_PORT}. Starting nginx."

exec "$@"