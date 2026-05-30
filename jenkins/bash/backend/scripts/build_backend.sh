#!/usr/bin/env bash
set -euo pipefail

echo "Running backend unit tests..."
./mvnw test -Dspring.profiles.active=hsqldb,spring-data-jpa

echo "Packaging backend..."
./mvnw clean package -DskipTests
