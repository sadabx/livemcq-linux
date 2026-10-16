#!/usr/bin/env bash
# ==============================================================================
# Build standalone AppImage for Live MCQ
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/dist"
APP_DIR_BUILD="/tmp/LiveMCQ.AppDir"
APPIMAGE_NAME="LiveMCQ-x86_64.AppImage"
INPUT_TARGET="${1:-}"

TEMP_EXTRACT_DIR=""
cleanup() {
    rm -rf "$APP_DIR_BUILD"
    if [[ -n "$TEMP_EXTRACT_DIR" && -d "$TEMP_EXTRACT_DIR" ]]; then
        rm -rf "$TEMP_EXTRACT_DIR"
    fi
}
trap cleanup EXIT

# 1. Resolve source target
SOURCE_DIR=""

if [[ -n "$INPUT_TARGET" ]]; then
    if [[ -d "$INPUT_TARGET" && -f "$INPUT_TARGET/livemcq_flutter.exe" ]]; then
        SOURCE_DIR="$INPUT_TARGET"
    elif [[ -f "$INPUT_TARGET" ]]; then
        echo "[INFO] Extracting archive: $INPUT_TARGET"
        TEMP_EXTRACT_DIR="$(mktemp -d /tmp/livemcq-extract.XXXXXX)"
        if command -v 7z &>/dev/null; then
            7z x "$INPUT_TARGET" -o"$TEMP_EXTRACT_DIR" -y >/dev/null
        elif command -v unzip &>/dev/null; then
            unzip -q "$INPUT_TARGET" -d "$TEMP_EXTRACT_DIR"
        else
            echo "[ERROR] Neither 7z nor unzip found to extract $INPUT_TARGET" >&2
            exit 1
        fi
        SOURCE_DIR="$TEMP_EXTRACT_DIR"
    else
        echo "[ERROR] Invalid input path: '$INPUT_TARGET'" >&2
        echo "Usage: ./build-appimage.sh [path-to-extracted-folder | path-to-package.Msix]" >&2
        exit 1
    fi
else
    # Auto-detect: check repository root or Downloads
    MSIX_FOUND="$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.Msix" -print -quit 2>/dev/null || true)"
    if [[ -n "$MSIX_FOUND" && -f "$MSIX_FOUND" ]]; then
        echo "[INFO] Auto-detected package: $(basename "$MSIX_FOUND")"
        TEMP_EXTRACT_DIR="$(mktemp -d /tmp/livemcq-extract.XXXXXX)"
        if command -v 7z &>/dev/null; then
            7z x "$MSIX_FOUND" -o"$TEMP_EXTRACT_DIR" -y >/dev/null
        elif command -v unzip &>/dev/null; then
            unzip -q "$MSIX_FOUND" -d "$TEMP_EXTRACT_DIR"
        else
            echo "[ERROR] Neither 7z nor unzip found." >&2
            exit 1
        fi
        SOURCE_DIR="$TEMP_EXTRACT_DIR"
    elif [[ -d "$HOME/Downloads/LiveMCQ_Windows" && -f "$HOME/Downloads/LiveMCQ_Windows/livemcq_flutter.exe" ]]; then
        SOURCE_DIR="$HOME/Downloads/LiveMCQ_Windows"
    elif [[ -d "$SCRIPT_DIR/LiveMCQ_Windows" && -f "$SCRIPT_DIR/LiveMCQ_Windows/livemcq_flutter.exe" ]]; then
        SOURCE_DIR="$SCRIPT_DIR/LiveMCQ_Windows"
    fi
fi

if [[ -z "$SOURCE_DIR" || ! -f "$SOURCE_DIR/livemcq_flutter.exe" ]]; then
    echo "[ERROR] Could not find livemcq_flutter.exe" >&2
    echo "Usage: ./build-appimage.sh [path-to-extracted-windows-folder | path-to-package.Msix]" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -rf "$APP_DIR_BUILD"
mkdir -p "$APP_DIR_BUILD/app"

echo "[INFO] Setting up AppDir structure..."

# Copy app files
cp -r "$SOURCE_DIR"/* "$APP_DIR_BUILD/app/"
# Clean unneeded Windows Store metadata
rm -rf "$APP_DIR_BUILD/app/Appx"* "$APP_DIR_BUILD/app/[Content_Types].xml"

# Copy App Icon
ICON_SRC="$SCRIPT_DIR/assets/icon.png"
if [[ -f "$ICON_SRC" ]]; then
    cp "$ICON_SRC" "$APP_DIR_BUILD/livemcq.png"
elif [[ -f "$SOURCE_DIR/Images/Square150x150Logo.scale-200.png" ]]; then
    cp "$SOURCE_DIR/Images/Square150x150Logo.scale-200.png" "$APP_DIR_BUILD/livemcq.png"
fi
ln -sf livemcq.png "$APP_DIR_BUILD/.DirIcon"

# Create Desktop entry
cat << 'EOF' > "$APP_DIR_BUILD/livemcq.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Live MCQ
GenericName=Live MCQ Desktop
Comment=Live Model Tests & Exam Preparation Platform
Exec=AppRun %U
Icon=livemcq
Terminal=false
Categories=Education;
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
    MSG="Wine is required to run Live MCQ.\n\nPlease install it using your package manager:\n  - Ubuntu/Debian: sudo apt install wine\n  - Arch/Manjaro: sudo pacman -S wine\n  - Fedora: sudo dnf install wine"
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

# 2. Acquire appimagetool if not installed
TOOL="/tmp/appimage-build/appimagetool"
if ! command -v appimagetool &> /dev/null && [[ ! -f "$TOOL" ]]; then
    echo "[INFO] Downloading appimagetool..."
    mkdir -p /tmp/appimage-build
    curl -fSL https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -o "$TOOL"
    chmod +x "$TOOL"
fi

if command -v appimagetool &> /dev/null; then
    APPIMAGETOOL="appimagetool"
else
    APPIMAGETOOL="$TOOL"
fi

echo "[INFO] Generating AppImage with appimagetool..."
OUTPUT_APPIMAGE="$OUTPUT_DIR/$APPIMAGE_NAME"

if [[ -f "$TOOL" ]] && ! "$APPIMAGETOOL" --version &>/dev/null; then
    ARCH=x86_64 "$APPIMAGETOOL" --appimage-extract-and-run -n "$APP_DIR_BUILD" "$OUTPUT_APPIMAGE"
else
    ARCH=x86_64 "$APPIMAGETOOL" -n "$APP_DIR_BUILD" "$OUTPUT_APPIMAGE"
fi

SIZE="$(du -h "$OUTPUT_APPIMAGE" | cut -f1)"
echo "[OK] AppImage successfully generated: $OUTPUT_APPIMAGE ($SIZE)"
echo "[INFO] Run with: chmod +x $APPIMAGE_NAME && ./$APPIMAGE_NAME"
