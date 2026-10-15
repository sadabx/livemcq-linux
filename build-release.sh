#!/usr/bin/env bash
# ==============================================================================
# Helper to package the extracted Windows app into a clean release tarball
# ==============================================================================

set -e

SOURCE_DIR="${1:-$HOME/Downloads/LiveMCQ_Windows}"
OUTPUT_DIR="dist"
ARCHIVE_NAME="livemcq-linux-x64.tar.gz"

if [ ! -f "$SOURCE_DIR/livemcq_flutter.exe" ]; then
    echo "Error: Could not find livemcq_flutter.exe in '$SOURCE_DIR'"
    echo "Usage: ./build-release.sh [path-to-extracted-windows-folder]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Creating $OUTPUT_DIR/$ARCHIVE_NAME from $SOURCE_DIR..."

tar --exclude='Appx*' \
    --exclude='[Content_Types].xml' \
    -czf "$OUTPUT_DIR/$ARCHIVE_NAME" \
    -C "$SOURCE_DIR" .

echo "✓ Created $OUTPUT_DIR/$ARCHIVE_NAME ($(du -h "$OUTPUT_DIR/$ARCHIVE_NAME" | cut -f1))"
echo "You can now attach this file to your GitHub Release under tag v1.7.0"
