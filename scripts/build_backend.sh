#!/usr/bin/env bash
set -euo pipefail

echo "Running backend unit tests..."
./mvnw test

echo "Packaging backend..."
./mvnw clean package -DskipTests
