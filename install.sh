#!/usr/bin/env bash
# ==============================================================================
# Live MCQ Linux Desktop Installer
# Official wrapper and native desktop integration for Live MCQ on GNU/Linux
# ==============================================================================

set -euo pipefail

GITHUB_REPO="${GITHUB_REPO:-sadabx/livemcq-linux}"
VERSION="${VERSION:-latest}"

if [[ "$VERSION" == "latest" ]]; then
    RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/livemcq-linux-x64.tar.gz"
else
    [[ "$VERSION" != v* ]] && VERSION="v$VERSION"
    RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/livemcq-linux-x64.tar.gz"
fi

RAW_ICON_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/assets/icon.png"

INSTALL_DIR="$HOME/.local/share/LiveMCQ"
APP_DIR="$INSTALL_DIR/app"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}==================================================${NC}"
echo -e "${GREEN}${BOLD}       Live MCQ Desktop Installer for Linux       ${NC}"
echo -e "${BLUE}${BOLD}==================================================${NC}\n"

# 1. Dependency Verification
if ! command -v wine &>/dev/null; then
    echo -e "${RED}[ERROR] Wine is required to run Live MCQ Desktop.${NC}\n"
    echo "Install Wine using your distribution package manager:"
    if [[ -f /etc/arch-release ]]; then
        echo -e "  ${YELLOW}sudo pacman -S wine${NC}"
    elif [[ -f /etc/debian_version ]]; then
        echo -e "  ${YELLOW}sudo apt update && sudo apt install wine${NC}"
    elif [[ -f /etc/fedora-release ]]; then
        echo -e "  ${YELLOW}sudo dnf install wine${NC}"
    else
        echo -e "  ${YELLOW}Install 'wine' using your distribution package manager.${NC}"
    fi
    echo ""
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Wine runtime detected: $(wine --version)"

# 2. Prepare target directories
mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# 3. Source resolution
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
fi

LOCAL_SOURCE=""
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/livemcq_flutter.exe" ]]; then
    LOCAL_SOURCE="$SCRIPT_DIR"
elif [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/LiveMCQ_Windows" && -f "$SCRIPT_DIR/LiveMCQ_Windows/livemcq_flutter.exe" ]]; then
    LOCAL_SOURCE="$SCRIPT_DIR/LiveMCQ_Windows"
elif [[ -d "$HOME/Downloads/LiveMCQ_Windows" && -f "$HOME/Downloads/LiveMCQ_Windows/livemcq_flutter.exe" ]]; then
    LOCAL_SOURCE="$HOME/Downloads/LiveMCQ_Windows"
fi

if [[ -n "$LOCAL_SOURCE" ]]; then
    echo -e "${BLUE}[INFO]${NC} Deploying app files from local directory: ${LOCAL_SOURCE}"
    cp -r "$LOCAL_SOURCE"/* "$APP_DIR/"
else
    echo -e "${BLUE}[INFO]${NC} Fetching Live MCQ binary package (${VERSION})..."
    TMP_TAR="$(mktemp /tmp/livemcq-pkg.XXXXXX.tar.gz)"
    
    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar "$RELEASE_URL" -o "$TMP_TAR"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress "$RELEASE_URL" -O "$TMP_TAR"
    else
        echo -e "${RED}[ERROR] Neither curl nor wget is available.${NC}"
        exit 1
    fi

    echo -e "${BLUE}[INFO]${NC} Extracting application payload..."
    tar -xzf "$TMP_TAR" -C "$APP_DIR"
    rm -f "$TMP_TAR"
fi

# Clean unnecessary Windows Store metadata if present
rm -rf "$APP_DIR/Appx"* "$APP_DIR/[Content_Types].xml"

# 4. Icon Installation
INSTALLED_ICON="$ICON_DIR/livemcq.png"
if [[ -f "$APP_DIR/Images/Square44x44Logo.altform-unplated_targetsize-256.png" ]]; then
    cp "$APP_DIR/Images/Square44x44Logo.altform-unplated_targetsize-256.png" "$INSTALLED_ICON"
elif [[ -f "$APP_DIR/Images/Square150x150Logo.scale-200.png" ]]; then
    cp "$APP_DIR/Images/Square150x150Logo.scale-200.png" "$INSTALLED_ICON"
elif [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/assets/icon.png" ]]; then
    cp "$SCRIPT_DIR/assets/icon.png" "$INSTALLED_ICON"
else
    # Fetch fallback icon
    if command -v curl &>/dev/null; then
        curl -fsSL "$RAW_ICON_URL" -o "$INSTALLED_ICON" 2>/dev/null || true
    fi
fi

# 5. Create CLI launcher script
LAUNCHER="$BIN_DIR/livemcq"
cat << 'EOF' > "$LAUNCHER"
#!/usr/bin/env bash
set -e
export WINEDEBUG=-all
export WINEPREFIX="${WINEPREFIX:-$HOME/.local/share/LiveMCQ/wineprefix}"
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
Comment=Live Model Tests and Exam Preparation Platform
Exec=$LAUNCHER %U
Path=$APP_DIR
Icon=livemcq
Terminal=false
Categories=Education;
StartupNotify=true
StartupWMClass=livemcq_flutter.exe
MimeType=x-scheme-handler/livemcq;
Keywords=livemcq;bcs;exam;mcq;model test;cracktech;
EOF

# 7. Update System Caches
command -v update-desktop-database &>/dev/null && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
command -v gtk-update-icon-cache &>/dev/null && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}[SUCCESS] Live MCQ Desktop installed successfully!${NC}"
echo -e "--------------------------------------------------"
echo -e "Launch methods:"
echo -e "  - Application Menu: Search for ${BOLD}Live MCQ${NC}"
echo -e "  - Terminal:         Run ${YELLOW}$LAUNCHER${NC}"
echo -e "--------------------------------------------------\n"
