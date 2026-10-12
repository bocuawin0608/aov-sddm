#!/usr/bin/env bash
# ==============================================================================
# Test Installer & Uninstaller (Dry-run, Idempotency, Safe Directory Testing)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Installer & Uninstaller Tests ==="

# 1. Test Dry Run Mode
echo "1. Testing installer --dry-run (default behavior sets theme as default)..."
DRY_OUTPUT=$("${ROOT_DIR}/scripts/install.sh" --dry-run)
if echo "${DRY_OUTPUT}" | grep -q "Running in DRY-RUN mode" && \
   echo "${DRY_OUTPUT}" | grep -q "Configuring SDDM to use theme 'aov-sddm' as default" && \
   echo "${DRY_OUTPUT}" | grep -q "Active Theme: aov-sddm"; then
    echo "  [PASS] Installer dry-run executed properly and verifies default setup."
else
    echo "  [FAIL] Installer dry-run failed!" >&2
    exit 1
fi

echo "1b. Testing installer --dry-run with --no-set-default..."
DRY_NO_DEFAULT=$("${ROOT_DIR}/scripts/install.sh" --dry-run --no-set-default)
if echo "${DRY_NO_DEFAULT}" | grep -q "SDDM configuration was not modified"; then
    echo "  [PASS] --no-set-default properly skips SDDM configuration."
else
    echo "  [FAIL] --no-set-default did not skip SDDM configuration!" >&2
    exit 1
fi

# 2. Test Custom Path Installation & Idempotency
TEST_DIR=$(mktemp -d "/tmp/aov_test_install.XXXXXX")
trap 'rm -rf "${TEST_DIR}"' EXIT

echo "2. Testing installation into isolated directory: ${TEST_DIR}..."
"${ROOT_DIR}/scripts/install.sh" --theme-dir "${TEST_DIR}" --no-deps > /dev/null

if [[ -f "${TEST_DIR}/Main.qml" && -f "${TEST_DIR}/metadata.desktop" && -d "${TEST_DIR}/components" && -d "${TEST_DIR}/assets" ]]; then
    echo "  [PASS] Installation placed all expected files in target directory."
else
    echo "  [FAIL] Target directory is missing expected files!" >&2
    exit 1
fi

echo "3. Testing installer idempotency (running second time)..."
"${ROOT_DIR}/scripts/install.sh" --theme-dir "${TEST_DIR}" --no-deps > /dev/null
echo "  [PASS] Second installation run succeeded without errors."

# 3. Test Uninstaller
echo "4. Testing uninstaller dry-run..."
UNINSTALL_DRY=$("${ROOT_DIR}/scripts/uninstall.sh" --dry-run --theme-dir "${TEST_DIR}")
if echo "${UNINSTALL_DRY}" | grep -q "Would remove theme directory"; then
    echo "  [PASS] Uninstaller dry-run executed properly."
else
    echo "  [FAIL] Uninstaller dry-run failed!" >&2
    exit 1
fi

echo "5. Testing uninstallation..."
"${ROOT_DIR}/scripts/uninstall.sh" --theme-dir "${TEST_DIR}" > /dev/null
if [[ ! -d "${TEST_DIR}" ]]; then
    echo "  [PASS] Uninstaller cleanly removed target theme directory."
else
    echo "  [FAIL] Target directory was not removed!" >&2
    exit 1
fi

echo "=== Installer & Uninstaller Tests Completed Successfully ==="

