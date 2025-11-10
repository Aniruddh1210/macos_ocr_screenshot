#!/usr/bin/env bash
# Simple launcher for OCR Screenshot app (path-independent)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/OCRScreenshot/OCRScreenshot"
