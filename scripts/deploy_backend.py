#!/usr/bin/env python3
"""Deploy backend to remote host via SSH."""

import subprocess
import sys
import os
import glob
import time

def check_env_var(var_name):
    """Check if environment variable exists."""
    if var_name not in os.environ:
        print(f"ERROR: {var_name} is required")
        sys.exit(1)
    return os.environ[var_name]

def run_command(cmd, description, check=True):
    """Run shell command."""
    print(f"\n{description}...")
    result = subprocess.run(cmd, shell=True)
    if check and result.returncode != 0:
        print(f"ERROR: {description} failed")
        sys.exit(result.returncode)
    return result.returncode

def main():
    # Verify environment variables
    backend_host = check_env_var("BACKEND_HOST")
    backend_user = check_env_var("BACKEND_USER")
    app_name = check_env_var("APP_NAME")
    app_port = check_env_var("APP_PORT")
    mysql_url = check_env_var("MYSQL_URL")
    mysql_user = check_env_var("MYSQL_USER")
    mysql_pass = check_env_var("MYSQL_PASS")
    spring_profiles = check_env_var("SPRING_PROFILES_ACTIVE")

    # Find JAR file
    jar_files = glob.glob("target/*.jar")
    if not jar_files:
        print("ERROR: No JAR file found in target/")
        sys.exit(1)
    jar_file = jar_files[0]

    print(f"Copying {jar_file} to {backend_host}...")
    run_command(
        f'scp "{jar_file}" {backend_user}@{backend_host}:/tmp/{app_name}.jar',
        "Copying JAR file"
    )

    print(f"\nStopping existing backend if running...")
    run_command(
        f"ssh {backend_user}@{backend_host} \"pgrep -f '[s]pring-petclinic-rest.jar' >/dev/null && pkill -f '[s]pring-petclinic-rest.jar' || true\"",
        "Stopping existing process",
        check=False
    )

    time.sleep(2)

    # Verify JAR copy
    run_command(
        f'ssh {backend_user}@{backend_host} "ls -lh /tmp/{app_name}.jar"',
        "Verifying JAR file was copied"
    )

    # Start backend
    ssh_cmd = f"""ssh {backend_user}@{backend_host} "
      export JENKINS_NODE_COOKIE=dontKillMe
      MYSQL_URL='{mysql_url}' \\
      MYSQL_USER='{mysql_user}' \\
      MYSQL_PASS='{mysql_pass}' \\
      SPRING_PROFILES_ACTIVE='{spring_profiles}' \\
      nohup java -jar /tmp/{app_name}.jar --server.port={app_port} --server.servlet.context-path=/petclinic \\
        > /tmp/{app_name}.log 2>&1 &
    " """

    print(f"\nStarting backend on {backend_host}:{app_port}...")
    run_command(ssh_cmd, "Starting backend process")

    time.sleep(5)

    # Verify process started
    run_command(
        f"ssh {backend_user}@{backend_host} \"pgrep -f '[s]pring-petclinic-rest.jar' || (echo 'ERROR: Java process failed to start'; cat /tmp/{app_name}.log; exit 1)\"",
        "Verifying backend process started"
    )

    print("\n✓ Backend deployment completed successfully!")

if __name__ == "__main__":
    main()
