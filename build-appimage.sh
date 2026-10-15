#!/usr/bin/env bash
# ==============================================================================
# Build standalone AppImage for Live MCQ
# ==============================================================================

set -e

SOURCE_DIR="${1:-$HOME/Downloads/LiveMCQ_Windows}"
OUTPUT_DIR="dist"
APP_DIR_BUILD="/tmp/LiveMCQ.AppDir"
APPIMAGE_NAME="LiveMCQ-x86_64.AppImage"

if [ ! -f "$SOURCE_DIR/livemcq_flutter.exe" ]; then
    echo "Error: Could not find livemcq_flutter.exe in '$SOURCE_DIR'"
    echo "Usage: ./build-appimage.sh [path-to-extracted-windows-folder]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -rf "$APP_DIR_BUILD"
mkdir -p "$APP_DIR_BUILD/app"

echo "==> Setting up AppDir structure..."

# Copy app files
cp -r "$SOURCE_DIR"/* "$APP_DIR_BUILD/app/"
# Clean unneeded Windows Store metadata
rm -rf "$APP_DIR_BUILD/app/Appx"* "$APP_DIR_BUILD/app/[Content_Types].xml"

# Copy App Icon
cp assets/icon.png "$APP_DIR_BUILD/livemcq.png"
ln -sf livemcq.png "$APP_DIR_BUILD/.DirIcon"

# Create Desktop entry
cat << 'EOF' > "$APP_DIR_BUILD/livemcq.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Live MCQ
GenericName=Live MCQ Desktop
Comment=Live Model Tests & Preparation for BCS, Bank & Govt. Jobs
Exec=AppRun %U
Icon=livemcq
Terminal=false
Categories=Education;Science;
StartupNotify=true
StartupWMClass=livemcq_flutter.exe
EOF

# Create AppRun entrypoint
cat << 'EOF' > "$APP_DIR_BUILD/AppRun"
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "$0")")"
export WINEDEBUG=-all
export WINEPREFIX="${WINEPREFIX:-$HOME/.local/share/LiveMCQ/wineprefix}"

# Check Wine availability
if ! command -v wine &> /dev/null; then
    TITLE="Live MCQ - Wine Required"
    MSG="Wine is required to run Live MCQ.\n\nPlease install it using your package manager:\n  • Ubuntu/Debian: sudo apt install wine\n  • Arch/Manjaro: sudo pacman -S wine\n  • Fedora: sudo dnf install wine"
    if command -v zenity &> /dev/null; then
        zenity --error --title="$TITLE" --text="$MSG" --width=400 2>/dev/null
    elif command -v kdialog &> /dev/null; then
        kdialog --error "$MSG" --title "$TITLE" 2>/dev/null
    else
        echo -e "$MSG" >&2
    fi
    exit 1
fi

cd "$HERE/app"
exec wine "$HERE/app/livemcq_flutter.exe" "$@"
EOF
chmod +x "$APP_DIR_BUILD/AppRun"

# 2. Get appimagetool if not installed
TOOL="/tmp/appimage-build/appimagetool"
if ! command -v appimagetool &> /dev/null && [ ! -f "$TOOL" ]; then
    echo "==> Downloading appimagetool..."
    mkdir -p /tmp/appimage-build
    curl -fSL https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -o "$TOOL"
    chmod +x "$TOOL"
fi

if command -v appimagetool &> /dev/null; then
    APPIMAGETOOL="appimagetool"
else
    APPIMAGETOOL="$TOOL"
fi

echo "==> Generating AppImage with appimagetool..."
ARCH=x86_64 "$APPIMAGETOOL" -n "$APP_DIR_BUILD" "$OUTPUT_DIR/$APPIMAGE_NAME"

# Cleanup
rm -rf "$APP_DIR_BUILD"

echo ""
echo "✓ AppImage successfully generated: $OUTPUT_DIR/$APPIMAGE_NAME ($(du -h "$OUTPUT_DIR/$APPIMAGE_NAME" | cut -f1))"
echo "Users can now download and run: chmod +x $APPIMAGE_NAME && ./$APPIMAGE_NAME"
