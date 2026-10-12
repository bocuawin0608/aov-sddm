#!/usr/bin/env bash
# ==============================================================================
# Arena of Valor (Liên Quân Mobile) SDDM Theme - Uninstaller
# ==============================================================================

set -euo pipefail

THEME_NAME="aov-sddm"
DEFAULT_TARGET_DIR="/usr/share/sddm/themes/${THEME_NAME}"
TARGET_DIR="${DEFAULT_TARGET_DIR}"
CONFIG_DROPIN_FILE="/etc/sddm.conf.d/zz-aov-theme.conf"
SDDM_DB_DIR="/var/lib/sddm/.local/share/sddm-greeter-qt6/QML/OfflineStorage"

DRY_RUN=false
PURGE_DATA=false
RESTORE_CONFIG=true

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

usage() {
    cat << EOF
${BOLD}Arena of Valor SDDM Theme Uninstaller${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --dry-run               Simulate uninstallation without removing files
  --theme-dir <PATH>      Custom installation path to remove (default: ${DEFAULT_TARGET_DIR})
  --purge-data            Also delete saved account preferences cache in SDDM storage
  --no-restore-config     Do not delete or restore SDDM drop-in theme configuration
  -h, --help              Show this help message

Examples:
  sudo ./scripts/uninstall.sh
  ./scripts/uninstall.sh --dry-run
  sudo ./scripts/uninstall.sh --purge-data

EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --theme-dir)
            if [[ -z "${2:-}" ]]; then
                log_error "Missing argument for --theme-dir"
                exit 1
            fi
            TARGET_DIR="$2"
            shift 2
            ;;
        --purge-data)
            PURGE_DATA=true
            shift
            ;;
        --no-restore-config)
            RESTORE_CONFIG=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# If custom non-system directory was targeted, do not touch system SDDM configuration
if [[ "${TARGET_DIR}" != "${DEFAULT_TARGET_DIR}" ]]; then
    RESTORE_CONFIG=false
fi

echo -e "${CYAN}${BOLD}=== Arena of Valor SDDM Theme Uninstaller ===${NC}"
log_info "Target Theme Directory: ${TARGET_DIR}"

if [[ "${DRY_RUN}" == "false" && "${TARGET_DIR}" == /usr/* ]]; then
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "Uninstalling from '${TARGET_DIR}' requires root privileges."
        log_error "Please run with sudo: sudo $0 $*"
        exit 1
    fi
fi

# 1. Remove theme directory
if [[ -d "${TARGET_DIR}" ]]; then
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would remove theme directory: ${TARGET_DIR}"
    else
        log_info "Removing theme directory: ${TARGET_DIR}..."
        rm -rf "${TARGET_DIR}"
        log_success "Theme directory removed."
    fi
else
    log_info "Theme directory '${TARGET_DIR}' does not exist or has already been removed."
fi

# 2. Revert / remove SDDM configuration drop-in & main config
if [[ "${RESTORE_CONFIG}" == "true" ]]; then
    for dropin in "/etc/sddm.conf.d/zz-aov-theme.conf" "/etc/sddm.conf.d/99-aov-theme.conf"; do
        if [[ -f "${dropin}" ]]; then
            if [[ "${DRY_RUN}" == "true" ]]; then
                log_info "[DRY-RUN] Would remove SDDM drop-in configuration: ${dropin}"
            else
                log_info "Removing SDDM drop-in configuration '${dropin}'..."
                rm -f "${dropin}"
                log_success "SDDM configuration drop-in '${dropin}' removed."
            fi
        fi
    done

    MAIN_SDDM_CONF="/etc/sddm.conf"
    if [[ -f "${MAIN_SDDM_CONF}" ]]; then
        if grep -q "Current=${THEME_NAME}" "${MAIN_SDDM_CONF}"; then
            if [[ "${DRY_RUN}" == "true" ]]; then
                log_info "[DRY-RUN] Would revert Current=${THEME_NAME} in '${MAIN_SDDM_CONF}'"
            else
                LATEST_BACKUP=$(ls -t "${MAIN_SDDM_CONF}".backup.* 2>/dev/null | head -n 1 || true)
                if [[ -n "${LATEST_BACKUP}" && -f "${LATEST_BACKUP}" ]]; then
                    log_info "Restoring '${MAIN_SDDM_CONF}' from backup '${LATEST_BACKUP}'..."
                    cp -f "${LATEST_BACKUP}" "${MAIN_SDDM_CONF}"
                    log_success "Restored '${MAIN_SDDM_CONF}' from backup."
                else
                    FALLBACK_THEME="eos-breeze"
                    if [[ ! -d "/usr/share/sddm/themes/${FALLBACK_THEME}" ]]; then
                        FALLBACK_THEME="breeze"
                    fi
                    sed -i "s/Current=${THEME_NAME}/Current=${FALLBACK_THEME}/" "${MAIN_SDDM_CONF}"
                    log_success "Reverted '${MAIN_SDDM_CONF}' Current to '${FALLBACK_THEME}'."
                fi
            fi
        fi
    fi
fi

# 3. Purge cached accounts data if explicitly requested
if [[ "${PURGE_DATA}" == "true" ]]; then
    if [[ -d "${SDDM_DB_DIR}" ]]; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY-RUN] Would search and remove AoV SQLite caches in: ${SDDM_DB_DIR}"
        else
            log_info "Purging AoV cached preferences..."
            find "${SDDM_DB_DIR}" -name "*AovThemeDb*" -delete 2>/dev/null || true
            log_success "Cached preference data purged."
        fi
    fi
else
    log_info "Preserving user preferences (use --purge-data to remove cached usernames)."
fi

# 4. Summary & Recovery Instructions
echo -e "\n${GREEN}${BOLD}=== Uninstallation Complete ===${NC}"
echo "Theme '${THEME_NAME}' has been cleanly removed."
echo ""
echo "To verify active SDDM theme configuration:"
echo "  grep -rn 'Current=' /etc/sddm.conf.d/ /etc/sddm.conf 2>/dev/null || true"
echo ""
echo "To set a specific fallback theme (e.g. breeze, eos-breeze, or maldives):"
echo "  sudo mkdir -p /etc/sddm.conf.d"
echo "  echo -e '[Theme]\\nCurrent=eos-breeze' | sudo tee /etc/sddm.conf.d/10-theme.conf"
echo -e "${CYAN}Done!${NC}\n"

