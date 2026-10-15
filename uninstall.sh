#!/usr/bin/env bash
# ==============================================================================
# Live MCQ Linux Uninstaller
# Cleans up all installed files, shortcuts, and caches
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}Uninstalling Live MCQ for Linux...${NC}"

# Remove App directory
if [ -d "$HOME/.local/share/LiveMCQ" ]; then
    rm -rf "$HOME/.local/share/LiveMCQ"
    echo -e "${GREEN}[✓] Removed $HOME/.local/share/LiveMCQ${NC}"
fi

# Remove Launcher
if [ -f "$HOME/.local/bin/livemcq" ]; then
    rm -f "$HOME/.local/bin/livemcq"
    echo -e "${GREEN}[✓] Removed launcher script${NC}"
fi

# Remove Desktop file
if [ -f "$HOME/.local/share/applications/livemcq.desktop" ]; then
    rm -f "$HOME/.local/share/applications/livemcq.desktop"
    echo -e "${GREEN}[✓] Removed desktop shortcut${NC}"
fi

# Remove Icon
if [ -f "$HOME/.local/share/icons/hicolor/256x256/apps/livemcq.png" ]; then
    rm -f "$HOME/.local/share/icons/hicolor/256x256/apps/livemcq.png"
    echo -e "${GREEN}[✓] Removed icon${NC}"
fi

# Update caches
command -v update-desktop-database &> /dev/null && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
command -v gtk-update-icon-cache &> /dev/null && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}Live MCQ has been completely uninstalled.${NC}\n"
