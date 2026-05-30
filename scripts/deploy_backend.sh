#!/usr/bin/env bash
set -euo pipefail

: "${BACKEND_HOST:?BACKEND_HOST is required}"
: "${BACKEND_USER:?BACKEND_USER is required}"
: "${APP_NAME:?APP_NAME is required}"
: "${APP_PORT:?APP_PORT is required}"
: "${MYSQL_URL:?MYSQL_URL is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASS:?MYSQL_PASS is required}"
: "${SPRING_PROFILES_ACTIVE:?SPRING_PROFILES_ACTIVE is required}"

JAR_FILE="$(ls target/*.jar | head -n 1)"

echo "Copying ${JAR_FILE} to ${BACKEND_HOST}..."
scp "${JAR_FILE}" "${BACKEND_USER}@${BACKEND_HOST}:/tmp/${APP_NAME}.jar"

echo "Stopping existing backend if it is running..."
ssh "${BACKEND_USER}@${BACKEND_HOST}" "pgrep -f '[s]pring-petclinic-rest.jar' >/dev/null && pkill -f '[s]pring-petclinic-rest.jar' || true"

echo "Starting backend on ${BACKEND_HOST}:${APP_PORT}..."
ssh "${BACKEND_USER}@${BACKEND_HOST}" "
  MYSQL_URL='${MYSQL_URL}' \
  MYSQL_USER='${MYSQL_USER}' \
  MYSQL_PASS='${MYSQL_PASS}' \
  SPRING_PROFILES_ACTIVE='${SPRING_PROFILES_ACTIVE}' \
  nohup java -jar /tmp/${APP_NAME}.jar --server.port=${APP_PORT} \
    > /tmp/${APP_NAME}.log 2>&1 &
"
