#!/usr/bin/env bash
set -euo pipefail

echo "Running backend unit tests..."
./mvnw clean test

echo "Packaging backend..."
./mvnw package -DskipTests
