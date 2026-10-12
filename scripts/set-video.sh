#!/usr/bin/env bash
# ==============================================================================
# Arena of Valor SDDM Theme - Video & Background Customizer
# Allows easy insertion of any custom background video or image
# ==============================================================================

set -euo pipefail

SCRIPT_REAL="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_REAL}")" && pwd)"

# Find theme root directory
if [[ -f "${SCRIPT_DIR}/metadata.desktop" ]]; then
    SOURCE_DIR="${SCRIPT_DIR}"
elif [[ -f "${SCRIPT_DIR}/../metadata.desktop" ]]; then
    SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
    SOURCE_DIR="${PWD}"
fi

THEME_CONF="${SOURCE_DIR}/theme.conf"
BG_DIR="${SOURCE_DIR}/assets/backgrounds"
SYSTEM_THEME_DIR="/usr/share/sddm/themes/aov-sddm"

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    echo -e "${BOLD}Arena of Valor SDDM Theme - Custom Video Manager${NC}

Usage: $(basename "$0") <VIDEO_OR_IMAGE_PATH> [OPTIONS]

Options:
  --copy                  Copy the media file into assets/backgrounds/ (default: true)
  --keep-path             Keep absolute file path without copying into theme directory
  --preview               Launch SDDM greeter in test-mode immediately after setting
  -h, --help              Show this help message

Examples:
  ./set-video.sh ~/Videos/my_aov_background.mp4
  ./set-video.sh /path/to/animation.webm --preview
  sudo ./set-video.sh ~/Videos/login.mp4

Supported Formats:
  Videos: MP4 (.mp4), WebM (.webm), MKV (.mkv), MOV (.mov), AVI (.avi)
  Images: PNG (.png), JPG/JPEG (.jpg, .jpeg), WebP (.webp)
"
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

INPUT_FILE=""
COPY_FILE=true
PREVIEW=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy)
            COPY_FILE=true
            shift
            ;;
        --keep-path)
            COPY_FILE=false
            shift
            ;;
        --preview)
            PREVIEW=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "${INPUT_FILE}" ]]; then
                INPUT_FILE="$1"
            else
                log_error "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "${INPUT_FILE}" ]]; then
    log_error "No media file path specified."
    usage
    exit 1
fi

# Resolve absolute path of input file
if [[ ! -f "${INPUT_FILE}" ]]; then
    log_error "File does not exist: '${INPUT_FILE}'"
    exit 1
fi

INPUT_REAL="$(realpath "${INPUT_FILE}")"
FILE_EXT="${INPUT_REAL##*.}"
FILE_EXT_LOWER="$(echo "${FILE_EXT}" | tr '[:upper:]' '[:lower:]')"
FILE_BASE="$(basename "${INPUT_REAL}")"

log_info "Processing media file: '${INPUT_REAL}'"

# Determine media type
IS_VIDEO=false
IS_IMAGE=false

case "${FILE_EXT_LOWER}" in
    mp4|webm|mkv|mov|avi)
        IS_VIDEO=true
        ;;
    png|jpg|jpeg|webp)
        IS_IMAGE=true
        ;;
    *)
        # Inspect using file command if available
        MIME_TYPE="$(file --mime-type -b "${INPUT_REAL}" 2>/dev/null || true)"
        if [[ "${MIME_TYPE}" == video/* ]]; then
            IS_VIDEO=true
        elif [[ "${MIME_TYPE}" == image/* ]]; then
            IS_IMAGE=true
        else
            log_warn "File extension '.${FILE_EXT}' not recognized as common video or image."
            log_warn "Attempting to configure as video background..."
            IS_VIDEO=true
        fi
        ;;
esac

DEST_PATH=""
if [[ "${COPY_FILE}" == "true" ]]; then
    mkdir -p "${BG_DIR}"
    DEST_FILE="${BG_DIR}/${FILE_BASE}"
    if [[ "${INPUT_REAL}" != "${DEST_FILE}" ]]; then
        cp -f "${INPUT_REAL}" "${DEST_FILE}"
        chmod 644 "${DEST_FILE}"
        log_success "Copied file to '${DEST_FILE}'"
    fi
    DEST_PATH="assets/backgrounds/${FILE_BASE}"
else
    DEST_PATH="${INPUT_REAL}"
fi

# Update theme.conf in workspace
if [[ -f "${THEME_CONF}" ]]; then
    if [[ "${IS_VIDEO}" == "true" ]]; then
        sed -i 's|^backgroundType=.*|backgroundType=video|' "${THEME_CONF}"
        sed -i 's|^videoBackground=.*|videoBackground='"${DEST_PATH}"'|' "${THEME_CONF}"
        log_success "Updated workspace '${THEME_CONF}':"
        log_success "  backgroundType=video"
        log_success "  videoBackground=${DEST_PATH}"
    else
        sed -i 's|^backgroundType=.*|backgroundType=image|' "${THEME_CONF}"
        sed -i 's|^background=.*|background='"${DEST_PATH}"'|' "${THEME_CONF}"
        log_success "Updated workspace '${THEME_CONF}':"
        log_success "  backgroundType=image"
        log_success "  background=${DEST_PATH}"
    fi
fi

# If system theme directory is installed and writable, update it as well
if [[ -d "${SYSTEM_THEME_DIR}" ]]; then
    if [[ -w "${SYSTEM_THEME_DIR}" ]]; then
        SYS_BG_DIR="${SYSTEM_THEME_DIR}/assets/backgrounds"
        SYS_THEME_CONF="${SYSTEM_THEME_DIR}/theme.conf"
        mkdir -p "${SYS_BG_DIR}"
        if [[ "${COPY_FILE}" == "true" ]]; then
            cp -f "${INPUT_REAL}" "${SYS_BG_DIR}/${FILE_BASE}"
            chmod 644 "${SYS_BG_DIR}/${FILE_BASE}"
            SYS_DEST_PATH="assets/backgrounds/${FILE_BASE}"
        else
            SYS_DEST_PATH="${INPUT_REAL}"
        fi

        if [[ "${IS_VIDEO}" == "true" ]]; then
            sed -i 's|^backgroundType=.*|backgroundType=video|' "${SYS_THEME_CONF}"
            sed -i 's|^videoBackground=.*|videoBackground='"${SYS_DEST_PATH}"'|' "${SYS_THEME_CONF}"
        else
            sed -i 's|^backgroundType=.*|backgroundType=image|' "${SYS_THEME_CONF}"
            sed -i 's|^background=.*|background='"${SYS_DEST_PATH}"'|' "${SYS_THEME_CONF}"
        fi
        log_success "Synchronized changes directly to system theme in '${SYSTEM_THEME_DIR}'."
    else
        log_info "Note: To apply this video to the installed system theme, re-run with sudo:"
        log_info "  sudo ./set-video.sh \"${INPUT_REAL}\""
        log_info "Or reinstall the theme:"
        log_info "  sudo ./install.sh"
    fi
fi

echo -e "\n${GREEN}${BOLD}✓ Video background successfully configured!${NC}"
log_info "Configured video source: ${DEST_PATH}"

if [[ "${PREVIEW}" == "true" ]]; then
    echo -e "\n${BOLD}Launching preview in SDDM test mode...${NC}"
    "${SOURCE_DIR}/scripts/test-greeter.sh"
else
    echo -e "\nTo preview your new video background without logging out, run:"
    echo "  ./scripts/test-greeter.sh"
    echo ""
    echo "To deploy to system:"
    echo "  sudo ./install.sh"
fi
