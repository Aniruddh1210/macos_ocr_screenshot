#!/usr/bin/env bash
# Interactive screenshot -> Vision OCR -> copy to clipboard -> open in TextEdit
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMPDIR="/tmp"
IMG_BASE=$(mktemp "$TMPDIR/visionshot.XXXXXX")
IMG_PATH="${IMG_BASE}.png"
TXT_BASE=$(mktemp "$TMPDIR/visionocr.XXXXXX")
TXT_PATH="${TXT_BASE}.txt"

echo "Select area to screenshot..."
screencapture -i -x "$IMG_PATH"

if [ ! -s "$IMG_PATH" ]; then
  echo "No screenshot taken or file empty; exiting." >&2
  rm -f "$IMG_PATH" || true
  exit 1
fi

# Path to Swift tool (prefer compiled binary for speed)
VISION_CLI_BIN="${ROOT_DIR}/tools/vision_ocr/vision_ocr"
VISION_CLI_SRC="${ROOT_DIR}/tools/vision_ocr/main.swift"

if [ -x "$VISION_CLI_BIN" ]; then
  OCR_TEXT=$("$VISION_CLI_BIN" "$IMG_PATH" 2>/dev/null || true)
else
  if [ -f "$VISION_CLI_SRC" ]; then
    OCR_TEXT=$(swift "$VISION_CLI_SRC" "$IMG_PATH" 2>/dev/null || true)
  else
    echo "Vision CLI not found. Compile with: swiftc -o $VISION_CLI_BIN $VISION_CLI_SRC -framework Vision -framework AppKit" >&2
    exit 1
  fi
fi

echo "Running Vision OCR..."

if [ -z "$OCR_TEXT" ]; then
  printf "" | pbcopy
else
  printf "%s" "$OCR_TEXT" | pbcopy
fi

printf "%s" "$OCR_TEXT" > "$TXT_PATH"
open -a TextEdit "$TXT_PATH"
osascript -e 'display notification "Vision OCR complete — text copied to clipboard" with title "Screenshot OCR (Vision)"'

rm -f "$IMG_PATH"

exit 0
