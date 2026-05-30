#!/usr/bin/env bash
set -euo pipefail

: "${BACKEND_HOST:?BACKEND_HOST is required}"
: "${APP_PORT:?APP_PORT is required}"

HEALTH_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/actuator/health"
API_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/api/pettypes"

echo "Waiting for backend to complete database migrations and start up cleanly..."
MAX_ATTEMPTS=20
ATTEMPT=1
WAIT_INTERVAL=5

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  echo "[Attempt $ATTEMPT/$MAX_ATTEMPTS] Checking health endpoint: ${HEALTH_URL}..."

  if curl -s -m 5 -f "${HEALTH_URL}" > /dev/null 2>&1; then
    echo "✓ Backend successfully online!"
    break
  else
    CURL_EXIT=$?
    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
      echo "  → Backend not ready yet (curl exit: $CURL_EXIT). Waiting ${WAIT_INTERVAL}s before retry..."
      sleep $WAIT_INTERVAL
    fi
  fi

  ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
  echo "ERROR: Backend failed to respond to health check after $MAX_ATTEMPTS attempts (${MAX_ATTEMPTS}*${WAIT_INTERVAL}s = $(($MAX_ATTEMPTS * $WAIT_INTERVAL))s total)."
  exit 1
fi

echo "Validating API endpoints: ${API_URL}..."
curl -f "${API_URL}"
echo -e "\nSmoke test successfully passed!"
