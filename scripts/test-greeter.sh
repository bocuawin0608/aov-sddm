#!/usr/bin/env bash
# ==============================================================================
# Preview the Arena of Valor SDDM Theme in test mode
# ==============================================================================

set -euo pipefail

SCRIPT_REAL="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_REAL}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/metadata.desktop" ]]; then
    THEME_DIR="${SCRIPT_DIR}"
else
    THEME_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

echo "Launching SDDM Greeter in test mode for theme: ${THEME_DIR}"

if command -v sddm-greeter-qt6 &>/dev/null; then
    exec sddm-greeter-qt6 --test-mode --theme "${THEME_DIR}" "$@"
elif command -v sddm-greeter &>/dev/null; then
    exec sddm-greeter --test-mode --theme "${THEME_DIR}" "$@"
else
    echo "Error: Neither sddm-greeter-qt6 nor sddm-greeter found." >&2
    exit 1
fi

