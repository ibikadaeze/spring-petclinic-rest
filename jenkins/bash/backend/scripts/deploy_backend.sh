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

# Wait a moment for the old process to die
sleep 2

echo "Verifying jar file was copied..."
ssh "${BACKEND_USER}@${BACKEND_HOST}" "ls -lh /tmp/${APP_NAME}.jar"

echo "Starting backend on ${BACKEND_HOST}:${APP_PORT}..."
ssh "${BACKEND_USER}@${BACKEND_HOST}" "
  export JENKINS_NODE_COOKIE=dontKillMe
  MYSQL_URL='${MYSQL_URL}' \
  MYSQL_USER='${MYSQL_USER}' \
  MYSQL_PASS='${MYSQL_PASS}' \
  SPRING_PROFILES_ACTIVE='${SPRING_PROFILES_ACTIVE}' \
  nohup java -jar /tmp/${APP_NAME}.jar --server.port=${APP_PORT} --server.servlet.context-path=/petclinic \
    > /tmp/${APP_NAME}.log 2>&1 &
"

# Wait for the process to start (Spring Boot can take 10-15 seconds to bind to port)
sleep 5
echo "Verifying backend process started..."
ssh "${BACKEND_USER}@${BACKEND_HOST}" "pgrep -f '[s]pring-petclinic-rest.jar' || (echo 'ERROR: Java process failed to start'; cat /tmp/${APP_NAME}.log; exit 1)"
