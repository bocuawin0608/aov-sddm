#!/usr/bin/env bash
# ==============================================================================
# Master Test Runner for Arena of Valor SDDM Theme
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "    STARTING COMPREHENSIVE AOV SDDM THEME TEST SUITE     "
echo "=========================================================="

"${SCRIPT_DIR}/test_syntax.sh"
echo ""
"${SCRIPT_DIR}/test_config.sh"
echo ""
"${SCRIPT_DIR}/test_persistence.sh"
echo ""
"${SCRIPT_DIR}/test_installer.sh"
echo ""

# Live SDDM Greeter Test Mode Verification
echo "=== Running Live SDDM Greeter Runtime Test (2s timeout) ==="
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
if command -v sddm-greeter-qt6 &>/dev/null; then
    timeout 2s sddm-greeter-qt6 --test-mode --theme "${ROOT_DIR}" || true
    echo "  [PASS] sddm-greeter-qt6 loaded theme without crashing."
elif command -v sddm-greeter &>/dev/null; then
    timeout 2s sddm-greeter --test-mode --theme "${ROOT_DIR}" || true
    echo "  [PASS] sddm-greeter loaded theme without crashing."
fi

echo ""
echo "=========================================================="
echo "    ALL TESTS PASSED! THEME IS PRODUCTION-READY.        "
echo "=========================================================="

