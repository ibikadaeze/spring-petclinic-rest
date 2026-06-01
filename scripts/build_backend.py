#!/usr/bin/env python3
"""Build backend using Maven."""

import subprocess
import sys

def run_command(cmd, description, fail_on_error=True):
    """Run command and optionally exit on failure."""
    print(f"\n{description}...")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        if fail_on_error:
            print(f"ERROR: {description} failed with exit code {result.returncode}")
            sys.exit(result.returncode)
        else:
            print(f"⚠ WARNING: {description} had issues (exit code {result.returncode}) but continuing...")
    return result.returncode

def main():
    skip_tests = "--skip-tests" in sys.argv or "-st" in sys.argv

    # Extract --step argument
    step = "all"
    for i, arg in enumerate(sys.argv[1:]):
        if arg == "--step" and i + 1 < len(sys.argv) - 1:
            step = sys.argv[i + 2]
            break

    test_result = 0

    # Execute steps based on --step argument
    if step in ("test", "all"):
        test_result = run_command(
            "./mvnw clean test -Dspring.profiles.active=hsqldb,spring-data-jpa",
            "Running backend unit tests",
            fail_on_error=False
        )

    if step in ("compile", "all"):
        if skip_tests or step != "all":
            run_command(
                "./mvnw compile -DskipTests",
                "Compiling backend",
                fail_on_error=True
            )

    if step in ("package", "all"):
        run_command(
            "./mvnw package -DskipTests",
            "Packaging backend",
            fail_on_error=True
        )

    print(f"\n✓ Backend build completed successfully! (step: {step})")

    if test_result != 0:
        print("\n⚠ NOTE: Some tests failed, but package was built successfully.")
        print("Review test reports in: target/surefire-reports/")

if __name__ == "__main__":
    main()
