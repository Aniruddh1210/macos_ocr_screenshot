# OCR Screenshot — Native macOS App

A **simple, native macOS app** that takes a screenshot, runs OCR using Apple's Vision framework, and displays the recognized text in a **floating, selectable window** — just like macOS Live Text, but triggered by a keyboard shortcut.

## Why This Exists

macOS doesn't have a built-in shortcut to OCR any screenshot instantly. This app fixes that. One keyboard shortcut → select area → get selectable, copyable text immediately.

---

## Quick Start

### 1. The app is already compiled!

The native Swift app is ready to use:

```bash
/Users/aniruddh/projects/screenshotwithocr/OCRScreenshot/OCRScreenshot
```

Or use the launcher:

```bash
./run_ocr.sh
```

### 2. How it works

1. Run the app (via launcher or direct binary)
2. Select an area of your screen (just like Command+Shift+4)
3. A floating window appears with all recognized text
4. Text is **fully selectable** — highlight and copy what you need
5. Click "Copy All" to copy everything instantly
6. Close the window when done

---

## Bind to Command+Shift+3 (Recommended)

### Method 1: Using Shortcuts app (macOS Monterey+)

1. Open **Shortcuts** app
2. Click **+** to create a new shortcut
3. Search for "Run Shell Script" and add it
4. Set these options:
   - Shell: `/bin/zsh`
   - Pass input: `as arguments`
   - Script content:
     ```bash
     /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot/OCRScreenshot
     ```
5. Save the shortcut (name it "OCR Screenshot")
6. Click the (i) icon on your shortcut
7. Click **Add Keyboard Shortcut**
8. Press **Command+Shift+3**

**Important**: If Command+Shift+3 doesn't work, macOS may be using it for built-in screenshots. To override:

- Go to **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **Screenshots**
- Disable or reassign the default Command+Shift+3 shortcut
- Return to Shortcuts and reassign Command+Shift+3 to your OCR shortcut

### Method 2: Using Automator (older macOS or if Shortcuts doesn't work)

1. Open **Automator**
2. Create a new **Quick Action**
3. Set "Workflow receives" to **no input** in **any application**
4. Add action: **Run Shell Script**
   - Shell: `/bin/zsh`
   - Pass input: `as arguments`
   - Script:
     ```bash
     /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot/OCRScreenshot
     ```
5. Save as "OCR Screenshot"
6. Go to **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **Services**
7. Find "OCR Screenshot" under **General** and assign **Command+Shift+3**

---

## Features

✅ **Native macOS app** — no dependencies, no Python, no Homebrew required  
✅ **Uses Apple Vision** — the same OCR engine as Live Text  
✅ **Floating window** — stays on top, doesn't clutter your workspace  
✅ **Fully selectable text** — highlight and copy exactly what you need  
✅ **One-click "Copy All"** — copies entire result to clipboard instantly  
✅ **Fast** — compiled Swift binary, no interpreter overhead  
✅ **Privacy-focused** — all OCR happens locally on your Mac

---

## How to Rebuild (if you modify the source)

If you edit `OCRScreenshot/OCRScreenshot.swift`:

```bash
cd /Users/aniruddh/projects/screenshotwithocr
swiftc -parse-as-library \
  -o OCRScreenshot/OCRScreenshot \
  OCRScreenshot/OCRScreenshot.swift \
  -framework Cocoa \
  -framework Vision \
  -framework SwiftUI
```

---

## Troubleshooting

### "No text detected"

- Make sure you're selecting an area with **clear, readable text**
- Vision works best with printed text (not handwriting)
- Try selecting a larger area with higher-contrast text

### App doesn't run when I press the shortcut

- Check that you've **saved the Shortcut/Automator action**
- Make sure the shortcut isn't being intercepted by another app
- Try running the app manually first to ensure it works:
  ```bash
  /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot/OCRScreenshot
  ```

### Keyboard shortcut conflicts

- macOS reserves Command+Shift+3/4 for screenshots by default
- You **must** disable or reassign these in System Settings → Keyboard → Shortcuts → Screenshots first
- Alternative: use a different combo like **Control+Option+Command+3**

### Screenshot capture is cancelled

- When the crosshair appears, **click and drag** to select an area
- Press **Escape** if you want to cancel
- The app will close automatically if no selection is made

---

## Legacy Scripts (still available)

The project also includes shell script alternatives if you prefer:

- `scripts/ocrshot` — unified shell script (Vision + Tesseract fallback)
- `scripts/ocr_screenshot.sh` — Tesseract-only
- `scripts/ocr_screenshot_vision.sh` — Vision via Swift CLI
- `scripts/ocr_screenshot_debug.sh` — keeps images for debugging

These require additional dependencies (Tesseract via Homebrew). The native app is recommended for most users.

---

## What Makes This Different

Unlike the shell scripts, this **native app**:

- Shows a proper floating UI window (like Live Text)
- Has selectable text in a clean interface
- Doesn't open TextEdit as a workaround
- Is a single compiled binary (no shell interpreter)
- Launches faster and uses less memory

---

## License

Use it however you want. Modify, distribute, whatever. It's a simple utility that should have been built into macOS.

---

## Next Steps

1. **Test it**: Run `./run_ocr.sh` and select some text on your screen
2. **Bind it**: Follow the steps above to assign Command+Shift+3
3. **Use it**: OCR any text on your screen instantly

You're done. No more copying text from images manually.
