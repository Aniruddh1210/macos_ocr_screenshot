#!/usr/bin/env bash
# Test the unified scripts/ocrshot with a generated sample image (non-interactive)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

OCRSHOT="$ROOT_DIR/scripts/ocrshot"
SAMPLE_GEN="$ROOT_DIR/tools/sample_image/main.swift"
TMP_IMG="$(mktemp /tmp/ocr_unified.XXXXXX).png"

chmod +x "$OCRSHOT" || true

echo "Generating sample image at $TMP_IMG" >&2
swift "$SAMPLE_GEN" "$TMP_IMG" "Unified OCR test 456" >/dev/null

echo "Running unified ocrshot (vision engine) ..." >&2
OUT="$($OCRSHOT --engine vision --no-open --input "$TMP_IMG" 2>/dev/null)"

TXT_FILE=$(echo "$OUT" | awk '/^Text: /{print $2}')
if [ -z "${TXT_FILE:-}" ] || [ ! -f "$TXT_FILE" ]; then
  echo "TEST FAIL: Could not determine output text file path from ocrshot output" >&2
  echo "Output: $OUT" >&2
  exit 1
fi

CONTENT=$(cat "$TXT_FILE" || true)
rm -f "$TMP_IMG"

if echo "$CONTENT" | grep -q "Unified OCR test"; then
  echo "TEST PASS: ocrshot produced expected text" >&2
  exit 0
else
  echo "TEST FAIL: Expected text not found in ocrshot output" >&2
  echo "Content was: $CONTENT" >&2
  exit 1
fi
