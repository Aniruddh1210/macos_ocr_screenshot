#!/usr/bin/env bash
# Debug variant: keep image, save tesseract stderr to a log and do not remove files.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMPDIR="/tmp"
IMG_BASE=$(mktemp "$TMPDIR/ocrshot.debug.XXXXXX")
IMG_PATH="${IMG_BASE}.png"
TXT_BASE=$(mktemp "$TMPDIR/ocrtext.debug.XXXXXX")
TXT_PATH="${TXT_BASE}.txt"
LOG_PATH="$TMPDIR/ocr_debug.$(date +%s).log"

echo "Select area to screenshot..."
screencapture -i -x "$IMG_PATH"

if [ ! -s "$IMG_PATH" ]; then
  echo "No screenshot taken or file empty; exiting." >&2
  echo "IMG_PATH=$IMG_PATH" >> "$LOG_PATH"
  exit 1
fi

if ! command -v tesseract >/dev/null 2>&1; then
  echo "tesseract not found. Install it via: brew install tesseract" >&2
  exit 1
fi

TESS_LANG=${TESS_LANG:-eng}

echo "Running OCR (lang=$TESS_LANG)..." | tee -a "$LOG_PATH"
echo "Image: $IMG_PATH" | tee -a "$LOG_PATH"
FILE_SIZE=$(stat -f%z "$IMG_PATH" 2>/dev/null || echo "unknown")
echo "Image size bytes: $FILE_SIZE" | tee -a "$LOG_PATH"
DIMENSIONS=$(sips -g pixelHeight -g pixelWidth "$IMG_PATH" 2>/dev/null | awk '/pixelHeight/{h=$2}/pixelWidth/{w=$2} END {print w "x" h}')
echo "Image dimensions: $DIMENSIONS" | tee -a "$LOG_PATH"

# Run tesseract and capture stderr to log; keep stdout in variable
OCR_TEXT=$(tesseract "$IMG_PATH" stdout -l "$TESS_LANG" 2>>"$LOG_PATH" || true)
TESS_EXIT=$?
echo "tesseract exit code: $TESS_EXIT" | tee -a "$LOG_PATH"

if [ -z "$OCR_TEXT" ]; then
  echo "No OCR text detected." | tee -a "$LOG_PATH" >&2
  printf "" | pbcopy
else
  printf "%s" "$OCR_TEXT" | pbcopy
fi

printf "%s" "$OCR_TEXT" > "$TXT_PATH"
echo "Saved text to: $TXT_PATH" | tee -a "$LOG_PATH"
echo "Kept image at: $IMG_PATH" | tee -a "$LOG_PATH"
echo "Log: $LOG_PATH" | tee -a "$LOG_PATH"
echo "Previewing first 200 bytes of image (hex):" | tee -a "$LOG_PATH"
xxd -l 200 "$IMG_PATH" 2>/dev/null | tee -a "$LOG_PATH"

open -a TextEdit "$TXT_PATH"
osascript -e 'display notification "OCR debug complete — text copied to clipboard (debug)" with title "Screenshot OCR (debug)"'

echo "Done." | tee -a "$LOG_PATH"

exit 0
