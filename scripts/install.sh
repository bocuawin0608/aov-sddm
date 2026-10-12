#!/usr/bin/env bash
# ==============================================================================
# Arena of Valor (Liên Quân Mobile) SDDM Theme - Installer
# Target OS: Arch Linux, EndeavourOS, and Arch-based distributions
# ==============================================================================

set -euo pipefail

# Default configuration - resolve real script location even if invoked via symlink
SCRIPT_REAL="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_REAL}")" && pwd)"

# Determine theme root directory (where metadata.desktop resides)
if [[ -f "${SCRIPT_DIR}/metadata.desktop" ]]; then
    SOURCE_DIR="${SCRIPT_DIR}"
elif [[ -f "${SCRIPT_DIR}/../metadata.desktop" ]]; then
    SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
elif [[ -f "${PWD}/metadata.desktop" ]]; then
    SOURCE_DIR="${PWD}"
else
    SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

THEME_NAME="aov-sddm"
DEFAULT_TARGET_DIR="/usr/share/sddm/themes/${THEME_NAME}"
TARGET_DIR="${DEFAULT_TARGET_DIR}"
CONFIG_DROPIN_DIR="/etc/sddm.conf.d"
CONFIG_DROPIN_FILE="${CONFIG_DROPIN_DIR}/zz-aov-theme.conf"

DRY_RUN=false
SKIP_DEPS=false
SET_DEFAULT=true
STATIC_ONLY=false
EXPLICIT_SET_DEFAULT=false
EXPLICIT_NO_SET_DEFAULT=false

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
${BOLD}Arena of Valor SDDM Theme Installer${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --dry-run               Simulate installation actions without modifying system
  --set-default           Set this theme as active in SDDM configuration (default behavior)
  --no-set-default        Do not configure SDDM to use this theme as default
  --theme-dir <PATH>      Custom installation path (default: ${DEFAULT_TARGET_DIR})
  --static-only           Install static background only (skips qt6-multimedia)
  --no-deps               Skip dependency checks and package installation
  -h, --help              Show this help message

Examples:
  sudo ./scripts/install.sh
  sudo ./scripts/install.sh --no-set-default
  ./scripts/install.sh --dry-run
  sudo ./scripts/install.sh --theme-dir /usr/share/sddm/themes/custom-aov

EOF
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --set-default)
            SET_DEFAULT=true
            EXPLICIT_SET_DEFAULT=true
            shift
            ;;
        --no-set-default)
            SET_DEFAULT=false
            EXPLICIT_NO_SET_DEFAULT=true
            shift
            ;;
        --static-only)
            STATIC_ONLY=true
            shift
            ;;
        --no-deps)
            SKIP_DEPS=true
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

# If custom non-system directory was targeted and user didn't explicitly pass --set-default, do not alter SDDM config
if [[ "${TARGET_DIR}" != "${DEFAULT_TARGET_DIR}" && "${EXPLICIT_SET_DEFAULT}" != "true" ]]; then
    SET_DEFAULT=false
fi
if [[ "${EXPLICIT_NO_SET_DEFAULT}" == "true" ]]; then
    SET_DEFAULT=false
fi

echo -e "${CYAN}${BOLD}=== Arena of Valor SDDM Theme Installer ===${NC}"
log_info "Source Directory: ${SOURCE_DIR}"
log_info "Target Directory: ${TARGET_DIR}"
if [[ "${DRY_RUN}" == "true" ]]; then
    log_warn "Running in DRY-RUN mode. No changes will be written to disk."
fi

# 1. Distribution Check
log_info "Checking Linux distribution compatibility..."
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
    if [[ "${DISTRO_ID}" != "arch" && "${DISTRO_ID}" != "endeavouros" && "${DISTRO_ID}" != "manjaro" && "${DISTRO_LIKE}" != *"arch"* ]]; then
        log_warn "Detected distribution '${PRETTY_NAME:-$DISTRO_ID}' is not an Arch-based distribution."
        log_warn "Proceeding, but package manager steps might require manual attention."
    else
        log_success "Compatible Arch-based distribution detected: ${PRETTY_NAME:-$DISTRO_ID}"
    fi
else
    log_warn "Cannot read /etc/os-release. Distribution unknown."
fi

# 2. Privileges Check
if [[ "${DRY_RUN}" == "false" && "${TARGET_DIR}" == /usr/* ]]; then
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "Installation to system directory '${TARGET_DIR}' requires root privileges."
        log_error "Please run with sudo: sudo $0 $*"
        exit 1
    fi
fi

# 3. Dependencies Detection and Installation
if [[ "${SKIP_DEPS}" == "false" ]]; then
    log_info "Checking dependencies..."

    REQUIRED_PACKAGES=("sddm" "qt6-declarative" "qt6-svg" "qt6-5compat")
    if [[ "${STATIC_ONLY}" == "false" ]]; then
        REQUIRED_PACKAGES+=("qt6-multimedia" "qt6-multimedia-ffmpeg")
    fi

    MISSING_PACKAGES=()
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if pacman -Q "${pkg}" &>/dev/null; then
            log_info "  [✓] Dependency '${pkg}' is already installed."
        else
            log_warn "  [✗] Dependency '${pkg}' is missing."
            MISSING_PACKAGES+=("${pkg}")
        fi
    done

    if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY-RUN] Would install missing packages via pacman: ${MISSING_PACKAGES[*]}"
        else
            log_info "Installing missing dependencies: ${MISSING_PACKAGES[*]}..."
            if command -v pacman &>/dev/null; then
                pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
                log_success "Dependencies installed successfully."
            else
                log_error "pacman not found. Please install manually: ${MISSING_PACKAGES[*]}"
                exit 1
            fi
        fi
    else
        log_success "All required dependencies are satisfied."
    fi
fi

# 4. Install Theme Files
log_info "Installing theme files into '${TARGET_DIR}'..."
if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would create directory '${TARGET_DIR}'"
    log_info "[DRY-RUN] Would copy Main.qml, metadata.desktop, theme.conf, components/, and assets/ to '${TARGET_DIR}'"
    log_info "[DRY-RUN] Would set directory permissions to 755 and file permissions to 644"
else
    mkdir -p "${TARGET_DIR}"
    
    # Copy metadata, configs, and main script
    cp -f "${SOURCE_DIR}/metadata.desktop" "${TARGET_DIR}/"
    cp -f "${SOURCE_DIR}/Main.qml" "${TARGET_DIR}/"
    cp -f "${SOURCE_DIR}/theme.conf" "${TARGET_DIR}/"
    
    # Copy components and assets directories
    cp -r -f "${SOURCE_DIR}/components" "${TARGET_DIR}/"
    cp -r -f "${SOURCE_DIR}/assets" "${TARGET_DIR}/"
    
    # Ensure components/assets symlink exists inside destination
    if [[ ! -e "${TARGET_DIR}/components/assets" ]]; then
        ln -sf ../assets "${TARGET_DIR}/components/assets"
    fi

    # Set secure and readable permissions
    chmod -R u=rwX,go=rX "${TARGET_DIR}"
    log_success "Theme files successfully installed to '${TARGET_DIR}'."
fi

# 5. Configure SDDM Current Theme
if [[ "${SET_DEFAULT}" == "true" ]]; then
    log_info "Configuring SDDM to use theme '${THEME_NAME}' as default..."
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would create '${CONFIG_DROPIN_DIR}' if missing"
        log_info "[DRY-RUN] Would back up existing drop-in configuration if present"
        log_info "[DRY-RUN] Would write '${CONFIG_DROPIN_FILE}' with Current=${THEME_NAME}"
        log_info "[DRY-RUN] Would synchronize /etc/sddm.conf [Theme] Current=${THEME_NAME} if present"
    else
        mkdir -p "${CONFIG_DROPIN_DIR}"
        
        # Backup if drop-in file already exists
        if [[ -f "${CONFIG_DROPIN_FILE}" ]]; then
            BACKUP_FILE="${CONFIG_DROPIN_FILE}.backup.$(date +%s)"
            cp -f "${CONFIG_DROPIN_FILE}" "${BACKUP_FILE}"
            log_info "Backed up existing configuration to '${BACKUP_FILE}'."
        fi

        # Clean up any legacy drop-in
        rm -f "${CONFIG_DROPIN_DIR}/99-aov-theme.conf" 2>/dev/null || true

        # Write clean, isolated drop-in configuration
        # Note: 'zz-' prefix ensures it evaluates after distribution drop-ins like virtualkbd.conf
        cat << EOF > "${CONFIG_DROPIN_FILE}"
[Theme]
Current=${THEME_NAME}

[General]
InputMethod=
EOF
        chmod 644 "${CONFIG_DROPIN_FILE}"
        log_success "Wrote SDDM configuration drop-in at '${CONFIG_DROPIN_FILE}'."

        # IMPORTANT: Per sddm.conf(5), /etc/sddm.conf has highest precedence and overrides /etc/sddm.conf.d/
        # If /etc/sddm.conf exists, synchronize Current=${THEME_NAME} and clear InputMethod= to suppress virtual keyboard auto-popup
        MAIN_SDDM_CONF="/etc/sddm.conf"
        if [[ -f "${MAIN_SDDM_CONF}" ]]; then
            log_info "Checking '${MAIN_SDDM_CONF}' (takes highest precedence in SDDM)..."
            MAIN_BACKUP="${MAIN_SDDM_CONF}.backup.$(date +%s)"
            cp -f "${MAIN_SDDM_CONF}" "${MAIN_BACKUP}"
            log_info "Backed up '${MAIN_SDDM_CONF}' to '${MAIN_BACKUP}'."

            UPDATED_CONF=$(awk -v theme="${THEME_NAME}" '
            BEGIN { in_theme = 0; found_theme = 0; replaced_theme = 0; in_gen = 0; found_gen = 0; replaced_im = 0 }
            /^\[Theme\]/ {
                in_theme = 1
                found_theme = 1
                in_gen = 0
                print
                next
            }
            /^\[General\]/ {
                in_gen = 1
                found_gen = 1
                in_theme = 0
                print
                next
            }
            /^\[/ {
                if (in_theme && !replaced_theme) {
                    print "Current=" theme
                    replaced_theme = 1
                }
                if (in_gen && !replaced_im) {
                    print "InputMethod="
                    replaced_im = 1
                }
                in_theme = 0
                in_gen = 0
                print
                next
            }
            in_theme && /^[[:space:]]*Current=/ {
                print "Current=" theme
                replaced_theme = 1
                next
            }
            in_gen && /^[[:space:]]*InputMethod=/ {
                print "InputMethod="
                replaced_im = 1
                next
            }
            { print }
            END {
                if (in_theme && !replaced_theme) {
                    print "Current=" theme
                    replaced_theme = 1
                }
                if (in_gen && !replaced_im) {
                    print "InputMethod="
                    replaced_im = 1
                }
                if (!found_theme) {
                    print ""
                    print "[Theme]"
                    print "Current=" theme
                }
                if (!found_gen) {
                    print ""
                    print "[General]"
                    print "InputMethod="
                }
            }
            ' "${MAIN_SDDM_CONF}")

            echo "${UPDATED_CONF}" > "${MAIN_SDDM_CONF}"
            chmod 644 "${MAIN_SDDM_CONF}"
            log_success "Synchronized [Theme] Current=${THEME_NAME} and [General] InputMethod= in '${MAIN_SDDM_CONF}'."
        fi

        log_info "Active SDDM configurations currently on disk:"
        grep -rn "Current=" /etc/sddm.conf.d/ /etc/sddm.conf 2>/dev/null || true
    fi
else
    log_info "Theme installed. SDDM configuration was not modified (--no-set-default active)."
fi

# 6. Summary and Verification Instructions
echo -e "\n${GREEN}${BOLD}=== Installation Summary ===${NC}"
log_success "Theme Directory: ${TARGET_DIR}"
if [[ "${SET_DEFAULT}" == "true" ]]; then
    log_success "Active Theme: ${THEME_NAME} (configured in ${CONFIG_DROPIN_FILE})"
fi

echo -e "\n${BOLD}Testing & Verification:${NC}"
echo "To test the theme in a preview window without logging out:"
echo "  sddm-greeter-qt6 --test-mode --theme ${TARGET_DIR}"
echo ""
echo "To manually set this theme at any time:"
echo "  sudo mkdir -p /etc/sddm.conf.d"
echo "  echo -e '[Theme]\\nCurrent=${THEME_NAME}\\n\\n[General]\\nInputMethod=' | sudo tee /etc/sddm.conf.d/zz-aov-theme.conf"
echo ""
echo "To uninstall:"
echo "  sudo ./scripts/uninstall.sh"
echo -e "${CYAN}Done!${NC}\n"

