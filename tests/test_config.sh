#!/usr/bin/env bash
# ==============================================================================
# Test Metadata, Configuration, and Referenced Assets Integrity
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Configuration & Asset Integrity Validation ==="

# 1. Validate metadata.desktop
echo "1. Checking metadata.desktop..."
METADATA="${ROOT_DIR}/metadata.desktop"
if [[ ! -f "${METADATA}" ]]; then
    echo "  [FAIL] metadata.desktop not found!" >&2
    exit 1
fi

REQUIRED_META_KEYS=("Name" "Type" "MainScript" "ConfigFile" "Theme-API" "QtVersion")
for key in "${REQUIRED_META_KEYS[@]}"; do
    if grep -E "^${key}=" "${METADATA}" &>/dev/null; then
        VAL=$(grep -E "^${key}=" "${METADATA}" | cut -d= -f2-)
        echo "  [PASS] metadata.desktop has '${key}=${VAL}'"
    else
        echo "  [FAIL] metadata.desktop is missing required key '${key}'" >&2
        exit 1
    fi
done

# 2. Validate theme.conf
echo "2. Checking theme.conf..."
THEME_CONF="${ROOT_DIR}/theme.conf"
if [[ ! -f "${THEME_CONF}" ]]; then
    echo "  [FAIL] theme.conf not found!" >&2
    exit 1
fi

REQUIRED_CONF_KEYS=("background" "backgroundType" "videoBackground" "logo" "showTopLeftControls")
for key in "${REQUIRED_CONF_KEYS[@]}"; do
    if grep -E "^${key}=" "${THEME_CONF}" &>/dev/null; then
        VAL=$(grep -E "^${key}=" "${THEME_CONF}" | cut -d= -f2-)
        echo "  [PASS] theme.conf has '${key}=${VAL}'"
    else
        echo "  [FAIL] theme.conf is missing key '${key}'" >&2
        exit 1
    fi
done

# 3. Check referenced assets exist on disk
echo "3. Verifying referenced assets..."
ASSET_PATHS=(
    "assets/backgrounds/default.png"
    "assets/backgrounds/default.mp4"
    "assets/backgrounds/screenshot_reference.png"
    "assets/logos/origin_logo.png"
    "assets/logos/aov_logo.svg"
    "assets/logos/aov_crest.svg"
    "assets/icons/repair.svg"
    "assets/icons/game_5v5.svg"
    "assets/icons/badge_16.svg"
    "assets/icons/facebook.svg"
    "assets/icons/apple.svg"
    "assets/icons/garena.svg"
    "assets/icons/chevron_up.svg"
    "assets/icons/chevron_down.svg"
    "assets/icons/eye.svg"
    "assets/icons/eye_off.svg"
    "assets/icons/keyboard.svg"
    "assets/icons/user.svg"
    "assets/icons/key.svg"
    "assets/icons/check.svg"
    "assets/icons/trash.svg"
    "assets/icons/close.svg"
    "assets/icons/session_wayland.svg"
    "assets/icons/session_x11.svg"
    "assets/icons/session_hyprland.svg"
    "assets/icons/session_plasma.svg"
    "assets/icons/session_generic.svg"
    "assets/icons/power_shutdown.svg"
    "assets/icons/power_reboot.svg"
    "assets/icons/power_suspend.svg"
    "assets/icons/power_hibernate.svg"
    "assets/fonts/Orbitron-Bold.ttf"
)

for rel in "${ASSET_PATHS[@]}"; do
    full="${ROOT_DIR}/${rel}"
    if [[ -f "${full}" ]]; then
        echo "  [PASS] Asset exists: ${rel}"
    else
        echo "  [FAIL] Missing asset: ${rel}" >&2
        exit 1
    fi
done

echo "=== Configuration & Asset Validation Completed Successfully ==="

