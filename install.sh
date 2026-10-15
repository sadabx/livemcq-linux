#!/usr/bin/env bash
# ==============================================================================
# Live MCQ Linux Installer
# Runs the official Live MCQ Desktop app on Linux seamlessly via Wine
# ==============================================================================

set -e

# Default repository for downloading release assets when piped via curl
GITHUB_REPO="${GITHUB_REPO:-mrsadab/livemcq-linux}"
VERSION="${VERSION:-v1.7.0}"
RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/livemcq-linux-x64.tar.gz"

INSTALL_DIR="$HOME/.local/share/LiveMCQ"
APP_DIR="$INSTALL_DIR/app"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}   Live MCQ™ Desktop Installer for Linux ${NC}"
echo -e "${BLUE}${BOLD}========================================${NC}\n"

# 1. Check Wine dependency
if ! command -v wine &> /dev/null; then
    echo -e "${RED}[!] Wine is required but not installed.${NC}\n"
    echo "Please install Wine using your package manager:"
    if [ -f /etc/arch-release ]; then
        echo -e "  ${YELLOW}sudo pacman -S wine${NC}"
    elif [ -f /etc/debian_version ]; then
        echo -e "  ${YELLOW}sudo apt update && sudo apt install wine${NC}"
    elif [ -f /etc/fedora-release ]; then
        echo -e "  ${YELLOW}sudo dnf install wine${NC}"
    else
        echo -e "  ${YELLOW}Install 'wine' using your distribution's package manager.${NC}"
    fi
    echo ""
    exit 1
fi

echo -e "${GREEN}[✓] Found Wine:${NC} $(wine --version)"

# 2. Prepare target directories
mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# 3. Source files: either from local folder or download from GitHub release
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
LOCAL_SOURCE=""

# Check if running locally with files in script dir or downloads
if [ -f "$SCRIPT_DIR/livemcq_flutter.exe" ]; then
    LOCAL_SOURCE="$SCRIPT_DIR"
elif [ -d "$HOME/Downloads/LiveMCQ_Windows" ] && [ -f "$HOME/Downloads/LiveMCQ_Windows/livemcq_flutter.exe" ]; then
    LOCAL_SOURCE="$HOME/Downloads/LiveMCQ_Windows"
fi

if [ -n "$LOCAL_SOURCE" ]; then
    echo -e "${BLUE}[*] Copying app files from local source (${LOCAL_SOURCE})...${NC}"
    cp -r "$LOCAL_SOURCE"/* "$APP_DIR/"
else
    echo -e "${BLUE}[*] Downloading Live MCQ package (${VERSION})...${NC}"
    TMP_TAR="$(mktemp --suffix=.tar.gz)"
    if command -v curl &> /dev/null; then
        curl -fSL --progress-bar "$RELEASE_URL" -o "$TMP_TAR"
    elif command -v wget &> /dev/null; then
        wget -q --show-progress "$RELEASE_URL" -O "$TMP_TAR"
    else
        echo -e "${RED}[!] Neither curl nor wget was found. Please install one of them.${NC}"
        exit 1
    fi

    echo -e "${BLUE}[*] Extracting package...${NC}"
    tar -xzf "$TMP_TAR" -C "$APP_DIR"
    rm -f "$TMP_TAR"
fi

# 4. Install App Icon
if [ -f "$APP_DIR/Images/Square44x44Logo.altform-unplated_targetsize-256.png" ]; then
    cp "$APP_DIR/Images/Square44x44Logo.altform-unplated_targetsize-256.png" "$ICON_DIR/livemcq.png"
elif [ -f "$APP_DIR/Images/Square150x150Logo.scale-200.png" ]; then
    cp "$APP_DIR/Images/Square150x150Logo.scale-200.png" "$ICON_DIR/livemcq.png"
elif [ -f "$SCRIPT_DIR/assets/icon.png" ]; then
    cp "$SCRIPT_DIR/assets/icon.png" "$ICON_DIR/livemcq.png"
fi

# 5. Create launcher script
LAUNCHER="$BIN_DIR/livemcq"
cat << 'EOF' > "$LAUNCHER"
#!/usr/bin/env bash
export WINEDEBUG=-all
APP_DIR="$HOME/.local/share/LiveMCQ/app"

if [ ! -f "$APP_DIR/livemcq_flutter.exe" ]; then
    echo "Error: Live MCQ executable not found in $APP_DIR" >&2
    exit 1
fi

cd "$APP_DIR"
exec wine "$APP_DIR/livemcq_flutter.exe" "$@"
EOF
chmod +x "$LAUNCHER"

# 6. Create Desktop Entry
cat << EOF > "$DESKTOP_DIR/livemcq.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Live MCQ
GenericName=Live MCQ Desktop
Comment=Live Model Tests & Preparation for BCS, Bank & Govt. Jobs
Exec=sh -c 'cd "$APP_DIR" && exec wine "$APP_DIR/livemcq_flutter.exe"'
Icon=livemcq
Terminal=false
Categories=Education;Science;
StartupNotify=true
StartupWMClass=livemcq_flutter.exe
Keywords=livemcq;bcs;exam;mcq;model test;
EOF

# 7. Update caches if available
command -v update-desktop-database &> /dev/null && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
command -v gtk-update-icon-cache &> /dev/null && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}✓ Installation Successful!${NC}"
echo -e "--------------------------------------------------"
echo -e "You can now launch Live MCQ:"
echo -e "  1. From your application menu (search for ${BOLD}Live MCQ${NC})"
echo -e "  2. Or from your terminal by running: ${YELLOW}~/.local/bin/livemcq${NC}"
echo -e "--------------------------------------------------\n"
