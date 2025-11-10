#!/usr/bin/env bash
# Interactive screenshot -> OCR -> copy to clipboard -> open in TextEdit
# Requirements: macOS, Homebrew-installed tesseract (brew install tesseract)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMPDIR="/tmp"
IMG_BASE=$(mktemp "$TMPDIR/ocrshot.XXXXXX")
IMG_PATH="${IMG_BASE}.png"
TXT_BASE=$(mktemp "$TMPDIR/ocrtext.XXXXXX")
TXT_PATH="${TXT_BASE}.txt"

# Take an interactive screenshot. -i = interactively select, -x = do not play sound
# If you prefer full screen or window, change flags accordingly.
if ! command -v screencapture >/dev/null 2>&1; then
  echo "screencapture command not found (this should exist on macOS)." >&2
  exit 1
fi

echo "Select area to screenshot..."
screencapture -i -x "$IMG_PATH"

if [ ! -s "$IMG_PATH" ]; then
  echo "No screenshot taken or file empty; exiting." >&2
  rm -f "$IMG_PATH" || true
  exit 1
fi

# Ensure tesseract is available
if ! command -v tesseract >/dev/null 2>&1; then
  echo "tesseract not found. Install it via: brew install tesseract" >&2
  exit 1
fi

# Run OCR (default language: eng). To change language, set TESS_LANG environment variable.
TESS_LANG=${TESS_LANG:-eng}

echo "Running OCR (lang=$TESS_LANG)..."
# tesseract can write to stdout by using 'stdout' as the output file
OCR_TEXT=$(tesseract "$IMG_PATH" stdout -l "$TESS_LANG" 2>/dev/null || true)

if [ -z "$OCR_TEXT" ]; then
  echo "No OCR text detected." >&2
  # still copy empty string to clipboard to clear previous contents
  printf "" | pbcopy
else
  printf "%s" "$OCR_TEXT" | pbcopy
fi

# Save text to a file and open in TextEdit so user can select part of it if desired
printf "%s" "$OCR_TEXT" > "$TXT_PATH"
open -a TextEdit "$TXT_PATH"

# macOS notification (user-visible)
osascript -e 'display notification "OCR complete — text copied to clipboard" with title "Screenshot OCR"'

echo "Done. Text copied to clipboard and opened in TextEdit." 

# Keep the text file but remove the image to avoid clutter
rm -f "$IMG_PATH"

exit 0
