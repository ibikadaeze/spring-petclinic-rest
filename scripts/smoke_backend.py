#!/usr/bin/env python3
"""Smoke test backend health and API endpoints."""

import subprocess
import time
import sys
import os

def check_env_var(var_name):
    """Check if environment variable exists."""
    if var_name not in os.environ:
        print(f"ERROR: {var_name} is required")
        sys.exit(1)
    return os.environ[var_name]

def check_endpoint(url, attempt, max_attempts, wait_interval):
    """Check if endpoint is accessible."""
    cmd = f'curl -s -m 5 -f "{url}" > /dev/null 2>&1'
    result = subprocess.run(cmd, shell=True)

    if result.returncode == 0:
        return True

    if attempt < max_attempts:
        print(f"  → Backend not ready yet. Waiting {wait_interval}s before retry...")
        time.sleep(wait_interval)

    return False

def main():
    backend_host = check_env_var("BACKEND_HOST")
    app_port = check_env_var("APP_PORT")

    health_url = f"http://{backend_host}:{app_port}/petclinic/actuator/health"
    api_url = f"http://{backend_host}:{app_port}/petclinic/api/pettypes"

    max_attempts = 20
    wait_interval = 5

    print("Waiting for backend to complete database migrations and start up cleanly...")

    for attempt in range(1, max_attempts + 1):
        print(f"[Attempt {attempt}/{max_attempts}] Checking health endpoint: {health_url}...")

        if check_endpoint(health_url, attempt, max_attempts, wait_interval):
            print("✓ Backend successfully online!")
            break
    else:
        total_wait = max_attempts * wait_interval
        print(f"\nERROR: Backend failed to respond to health check after {max_attempts} attempts ({total_wait}s total).")
        sys.exit(1)

    # Validate API endpoint
    print(f"\nValidating API endpoints: {api_url}...")
    result = subprocess.run(f'curl -f "{api_url}"', shell=True)

    if result.returncode != 0:
        print("\nERROR: API validation failed")
        sys.exit(1)

    print("\n✓ Smoke test successfully passed!")

if __name__ == "__main__":
    main()
