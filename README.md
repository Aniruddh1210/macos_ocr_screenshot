# Screenshot-with-OCR

Small utility to take an interactive screenshot on macOS, run OCR, copy recognized text to the clipboard and open it in TextEdit for easy selection.

Files

- `scripts/ocrshot` — unified runner (Vision by default, falls back to Tesseract). Recommended.
- `scripts/ocr_screenshot.sh` — Tesseract-based runner.
- `scripts/ocr_screenshot_vision.sh` — Vision runner wrapper.
- `scripts/ocr_screenshot_debug.sh` — keeps image and logs for debugging.
- `scripts/ocr_screenshot_preprocess.sh` — enlarges + grayscales before OCR (Tesseract).
- `tools/vision_ocr/` — Swift Vision OCR CLI source and binary.
- `tools/sample_image/` — Swift sample image generator (optional, for testing).

Requirements

- macOS
- Xcode Command Line Tools (for the Swift Vision CLI)
- Optional: Homebrew + Tesseract (`brew install tesseract`) if you want the Tesseract path

Install and setup

### Quick Start (5 minutes)

1. **Clone and build**:

```bash
git clone https://github.com/yourusername/screenshotwithocr.git
cd screenshotwithocr
./build.sh
```

2. **Test it**:

```bash
./scripts/ocrshot
```

Select a region with text → OCR happens → text copied to clipboard + opens in TextEdit.

3. **Bind to Command+Shift+3**:

See **[SETUP_KEYBOARD_SHORTCUT.md](SETUP_KEYBOARD_SHORTCUT.md)** for step-by-step instructions.

---

### Detailed Setup

1. Install Homebrew (if you don't have it) — https://brew.sh

2. **(Optional)** Install tesseract for fallback OCR:

```bash
brew install tesseract
```

3. Build the Vision OCR CLI and native app:

```bash
./build.sh    # builds Vision CLI + native app
```

Or use `make` directly:

```bash
make vision   # Vision CLI only
make app      # Native floating window app
```

4. Run manually to test:

```bash
./scripts/ocrshot
```

It will prompt you to select an area of the screen. After selecting, OCR runs (Vision by default). The extracted text is copied to the clipboard, and a TextEdit window opens with the text for you to select parts or edit.

Use options:

```bash
# Force engine
./scripts/ocrshot --engine vision
./scripts/ocrshot --engine tesseract --lang eng

# Don’t open TextEdit
./scripts/ocrshot --no-open

# Keep the image for inspection
./scripts/ocrshot --keep
```

Keyboard shortcut setup (Command+Shift+3)

**See [SETUP_KEYBOARD_SHORTCUT.md](SETUP_KEYBOARD_SHORTCUT.md) for complete step-by-step instructions.**

Quick summary:

1. Open **Shortcuts** app (macOS 12+) or **Automator** (older macOS)
2. Create a new shortcut that runs: `/path/to/screenshotwithocr/scripts/ocrshot` (replace with your actual path)
3. Assign keyboard shortcut **Command+Shift+3**
4. Disable the default macOS screenshot shortcut if it conflicts (System Settings → Keyboard → Shortcuts → Screenshots)

After setup, press **Cmd+Shift+3** anywhere to OCR any screen region instantly.

Changing OCR language

- Set environment variable `TESS_LANG` before running script, e.g. `TESS_LANG=de ./scripts/ocr_screenshot.sh` for German.
- Or pass `--lang de` when using `ocrshot` with `--engine tesseract`.

Troubleshooting

- If you get "tesseract: command not found", install tesseract through Homebrew.
- If Vision returns empty but screenshot looks fine, try the Tesseract engine: `./scripts/ocrshot --engine tesseract`.
- If you see hard-coded absolute paths in older scripts, update to latest version (they now auto-detect project root).
- If Tesseract returns empty, try preprocessing: `./scripts/ocr_screenshot_preprocess.sh`.
- If OCR quality is poor, try different `tesseract` config options or preprocess the image (grayscale + enlarge) before feeding to Tesseract.
- For debugging paths and sizes, use: `./scripts/ocr_screenshot_debug.sh`.

Privacy

- The script writes a temporary PNG and a temporary text file under `/tmp`. The image is removed after OCR; the text file is kept and opened in TextEdit so you can inspect it. Delete the text file manually if desired.

License & improvements

- This is a minimal utility. Current improvements included: native floating window app, build script, automated test, path-independent scripts. Possible next steps: richer UI (search/filter), multi-language Vision OCR selection, live preview, configuration file, or integration with Shortcuts export.

Development quick refs

```bash
./build.sh          # build everything
make test           # run sample Vision OCR test
scripts/test_ocr.sh # invoke test directly
```
