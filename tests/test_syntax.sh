#!/usr/bin/env bash
# ==============================================================================
# Test QML & Shell Script Syntax
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Syntax Validation ==="

# 1. QML Syntax Validation via qmllint
echo "1. Validating QML files with qmllint..."
if command -v qmllint &>/dev/null; then
    qmllint "${ROOT_DIR}/Main.qml" "${ROOT_DIR}/components"/*.qml
    echo "  [PASS] All QML files passed qmllint validation without errors."
else
    echo "  [WARN] qmllint not found, skipping."
fi

# 2. Bash Syntax Validation via bash -n
echo "2. Validating Bash scripts with bash -n..."
for script in "${ROOT_DIR}/scripts"/*.sh "${ROOT_DIR}/tests"/*.sh; do
    if [[ -f "${script}" ]]; then
        bash -n "${script}"
        echo "  [PASS] $(basename "${script}") syntax is valid."
    fi
done

# 3. ShellCheck (if available)
echo "3. Checking ShellCheck..."
if command -v shellcheck &>/dev/null; then
    shellcheck "${ROOT_DIR}/scripts"/*.sh "${ROOT_DIR}/tests"/*.sh
    echo "  [PASS] ShellCheck passed."
else
    echo "  [INFO] shellcheck is not installed on this system (skipped)."
fi

echo "=== Syntax Validation Completed Successfully ==="

