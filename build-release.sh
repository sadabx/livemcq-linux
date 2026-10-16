#!/usr/bin/env bash
# ==============================================================================
# Helper to package the extracted Windows app into a clean release tarball
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/dist"
ARCHIVE_NAME="livemcq-linux-x64.tar.gz"
INPUT_TARGET="${1:-}"

TEMP_EXTRACT_DIR=""
cleanup() {
    if [[ -n "$TEMP_EXTRACT_DIR" && -d "$TEMP_EXTRACT_DIR" ]]; then
        rm -rf "$TEMP_EXTRACT_DIR"
    fi
}
trap cleanup EXIT

# 1. Resolve source directory or archive
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
        echo "Usage: ./build-release.sh [path-to-extracted-folder | path-to-package.Msix]" >&2
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
    echo "Usage: ./build-release.sh [path-to-extracted-windows-folder | path-to-package.Msix]" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"

echo "[INFO] Creating $OUTPUT_PATH from $SOURCE_DIR..."

tar --exclude='Appx*' \
    --exclude='[Content_Types].xml' \
    -czf "$OUTPUT_PATH" \
    -C "$SOURCE_DIR" .

SIZE="$(du -h "$OUTPUT_PATH" | cut -f1)"
echo "[OK] Successfully built release archive: $OUTPUT_PATH ($SIZE)"
