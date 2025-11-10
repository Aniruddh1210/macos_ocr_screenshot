#!/usr/bin/env bash
# Minimal automated test: generate sample image and run Vision OCR on it.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_VISION="$ROOT_DIR/bin/vision_ocr"
SAMPLE_GEN="$ROOT_DIR/tools/sample_image/main.swift"
TMP_IMG="$(mktemp /tmp/ocr_sample.XXXXXX).png"

if [ ! -x "$BIN_VISION" ]; then
  echo "Vision CLI not built; building now..." >&2
  (cd "$ROOT_DIR" && make vision) >/dev/null
fi

echo "Generating sample image at $TMP_IMG" >&2
swift "$SAMPLE_GEN" "$TMP_IMG" "Sample OCR 123 ABC" >/dev/null

echo "Running Vision OCR test..." >&2
OUT_TEXT="$($BIN_VISION "$TMP_IMG" 2>/dev/null || true)"
rm -f "$TMP_IMG"

if echo "$OUT_TEXT" | grep -q "Sample OCR"; then
  echo "TEST PASS: OCR output contains expected text" >&2
  exit 0
else
  echo "TEST FAIL: Expected text not found in OCR output" >&2
  echo "Output was: $OUT_TEXT" >&2
  exit 1
fi