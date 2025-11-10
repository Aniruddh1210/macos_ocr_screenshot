#!/usr/bin/env bash
# Hybrid approach: shell script captures, Swift app handles OCR + UI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}" && pwd)" # this script is at project root

TMPDIR="/tmp"
IMG_BASE=$(mktemp "$TMPDIR/hybridocr.XXXXXX")
IMG_PATH="${IMG_BASE}.png"

echo "Select area to screenshot..."
screencapture -i -x "$IMG_PATH"

if [ ! -s "$IMG_PATH" ]; then
  echo "No screenshot taken; exiting."
  exit 1
fi

echo "Running OCR..."
# Call our Swift OCR processor with the captured image
"${ROOT_DIR}/OCRProcessor" "$IMG_PATH"

# Clean up
rm -f "$IMG_PATH"