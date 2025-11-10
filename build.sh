#!/usr/bin/env bash
# Convenience build script wrapping the Makefile for users unfamiliar with make.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "swiftc not found. Install Xcode Command Line Tools first (xcode-select --install)." >&2
  exit 1
fi

echo "Building Vision CLI and App..."
chmod +x "$SCRIPT_DIR"/scripts/ocrshot || true
chmod +x "$SCRIPT_DIR"/scripts/*.sh || true
make build
echo "Done. Binaries:"
echo "  Vision CLI: $SCRIPT_DIR/bin/vision_ocr"
echo "  App:        $SCRIPT_DIR/OCRScreenshot/OCRScreenshot"