#!/usr/bin/env bash
set -euo pipefail

: "${BACKEND_HOST:?BACKEND_HOST is required}"
: "${APP_PORT:?APP_PORT is required}"

HEALTH_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/actuator/health"
API_URL="http://${BACKEND_HOST}:${APP_PORT}/petclinic/api/pettypes"

echo "Waiting for backend to start..."
sleep 20

echo "Checking ${HEALTH_URL}..."
curl -f "${HEALTH_URL}"

echo
echo "Checking ${API_URL}..."
curl -f "${API_URL}"
