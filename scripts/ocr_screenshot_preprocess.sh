#!/usr/bin/env bash
# Capture screenshot, preprocess (grayscale + enlarge), then OCR with tesseract.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMPDIR="/tmp"
RAW_BASE=$(mktemp "$TMPDIR/ocrpre.raw.XXXXXX")
RAW_IMG="${RAW_BASE}.png"
PROC_BASE=$(mktemp "$TMPDIR/ocrpre.proc.XXXXXX")
PROC_IMG="${PROC_BASE}.png"
TXT_BASE=$(mktemp "$TMPDIR/ocrpre.text.XXXXXX")
TXT_PATH="${TXT_BASE}.txt"
LOG_PATH="$TMPDIR/ocr_preprocess.$(date +%s).log"

echo "Select area to screenshot..."
screencapture -i -x "$RAW_IMG"

if [ ! -s "$RAW_IMG" ]; then
  echo "No screenshot captured." >&2
  exit 1
fi

if ! command -v tesseract >/dev/null 2>&1; then
  echo "tesseract not found. Install with: brew install tesseract" >&2
  exit 1
fi

# Preprocess with sips (native macOS tool): grayscale + resize to double width to make small text more legible
echo "Preprocessing image (grayscale + enlarge)..." | tee -a "$LOG_PATH"
sips -s format png -s formatOptions best -s colorModel Gray "$RAW_IMG" --out "$PROC_IMG" >>"$LOG_PATH" 2>&1 || true
WIDTH=$(sips -g pixelWidth "$PROC_IMG" 2>/dev/null | awk '/pixelWidth/{print $2}')
if [ -n "$WIDTH" ]; then
  NEW_WIDTH=$((WIDTH * 2))
  sips -Z "$NEW_WIDTH" "$PROC_IMG" >>"$LOG_PATH" 2>&1 || true
fi

TESS_LANG=${TESS_LANG:-eng}
echo "Running tesseract (lang=$TESS_LANG)..." | tee -a "$LOG_PATH"
OCR_TEXT=$(tesseract "$PROC_IMG" stdout -l "$TESS_LANG" -c preserve_interword_spaces=1 2>>"$LOG_PATH" || true)

if [ -z "$OCR_TEXT" ]; then
  echo "No OCR text detected (after preprocessing)." | tee -a "$LOG_PATH" >&2
  printf "" | pbcopy
else
  printf "%s" "$OCR_TEXT" | pbcopy
fi

printf "%s" "$OCR_TEXT" > "$TXT_PATH"
echo "Raw image: $RAW_IMG" | tee -a "$LOG_PATH"
echo "Processed image: $PROC_IMG" | tee -a "$LOG_PATH"
echo "Text file: $TXT_PATH" | tee -a "$LOG_PATH"
echo "Log file: $LOG_PATH" | tee -a "$LOG_PATH"

open -a TextEdit "$TXT_PATH"
osascript -e 'display notification "Preprocess OCR complete" with title "Screenshot OCR (Preprocess)"'

exit 0
