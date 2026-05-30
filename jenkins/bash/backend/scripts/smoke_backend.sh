#!/usr/bin/env bash
set -euo pipefail

: "${BACKEND_HOST:?BACKEND_HOST is required}"
: "${APP_PORT:?APP_PORT is required}"

# REMOVED '/petclinic' FROM THE PATH MAPPINGS
HEALTH_URL="http://${BACKEND_HOST}:${APP_PORT}/actuator/health"
API_URL="http://${BACKEND_HOST}:${APP_PORT}/api/pettypes"

echo "Waiting for backend to start up cleanly..."
MAX_ATTEMPTS=10
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  echo "Checking health endpoint (Attempt $ATTEMPT/$MAX_ATTEMPTS): ${HEALTH_URL}..."
  if curl -s -f "${HEALTH_URL}" > /dev/null; then
    echo "Backend successfully online!"
    break
  fi
  
  if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "ERROR: Backend failed to respond health check after $MAX_ATTEMPTS attempts."
    exit 1
  fi

  sleep 5
  ATTEMPT=$((ATTEMPT + 1))
done

echo "Validating API endpoints: ${API_URL}..."
curl -f "${API_URL}"
echo -e "\nSmoke test successfully passed!"
