#!/usr/bin/env bash
# ==============================================================================
# Live MCQ Linux Desktop Uninstaller
# Cleans up installed binaries, desktop entries, icons, and wine prefixes
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PURGE=false
if [[ "${1:-}" == "--purge" || "${1:-}" == "-p" ]]; then
    PURGE=true
fi

echo -e "${BLUE}${BOLD}[INFO] Removing Live MCQ Desktop for Linux...${NC}"

# Remove App directory
INSTALL_DIR="$HOME/.local/share/LiveMCQ"
if [[ -d "$INSTALL_DIR" ]]; then
    if [[ "$PURGE" == true ]]; then
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}[OK]${NC} Removed installation directory and wineprefix ($INSTALL_DIR)"
    else
        # Remove app binaries while leaving user wineprefix if desired, or remove all if wineprefix is default
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}[OK]${NC} Removed installation directory ($INSTALL_DIR)"
    fi
fi

# Remove Launcher
LAUNCHER="$HOME/.local/bin/livemcq"
if [[ -f "$LAUNCHER" ]]; then
    rm -f "$LAUNCHER"
    echo -e "${GREEN}[OK]${NC} Removed launcher executable ($LAUNCHER)"
fi

# Remove Desktop file
DESKTOP_FILE="$HOME/.local/share/applications/livemcq.desktop"
if [[ -f "$DESKTOP_FILE" ]]; then
    rm -f "$DESKTOP_FILE"
    echo -e "${GREEN}[OK]${NC} Removed desktop entry ($DESKTOP_FILE)"
fi

# Remove Icon
ICON_FILE="$HOME/.local/share/icons/hicolor/256x256/apps/livemcq.png"
if [[ -f "$ICON_FILE" ]]; then
    rm -f "$ICON_FILE"
    echo -e "${GREEN}[OK]${NC} Removed application icon ($ICON_FILE)"
fi

# Update system caches
command -v update-desktop-database &>/dev/null && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
command -v gtk-update-icon-cache &>/dev/null && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}[SUCCESS] Live MCQ has been successfully uninstalled.${NC}\n"
