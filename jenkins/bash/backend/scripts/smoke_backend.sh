#!/usr/bin/env bash
set -euo pipefail

: "${BACKEND_HOST:?BACKEND_HOST is required}"
: "${APP_PORT:?APP_PORT is required}"

# KEEPING THE REQUIRED /petclinic CONTEXT PREFIX
HEALTH_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/actuator/health"
API_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/api/pettypes"

echo "Waiting for backend to complete database migrations and start up cleanly..."
MAX_ATTEMPTS=15
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  echo "Checking health endpoint (Attempt $ATTEMPT/$MAX_ATTEMPTS): ${HEALTH_URL}..."
  if curl -s -f "${HEALTH_URL}" > /dev/null; then
    echo "Backend successfully online!"
    break
  fi
  
  if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "ERROR: Backend failed to respond to health check after $MAX_ATTEMPTS attempts."
    exit 1
  fi

  # Wait 5 seconds between checks (15 attempts x 5s = up to 75 seconds total wait time)
  sleep 5
  ATTEMPT=$((ATTEMPT + 1))
done

echo "Validating API endpoints: ${API_URL}..."
curl -f "${API_URL}"
echo -e "\nSmoke test successfully passed!"
