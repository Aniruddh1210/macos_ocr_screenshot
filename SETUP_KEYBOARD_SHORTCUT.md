# Setting Up Cmd+Shift+3 for OCR Screenshot

This guide will help you bind **Command+Shift+3** to instantly trigger OCR on any selected screen region.

---

## Option 1: macOS Shortcuts App (Recommended - Monterey 12+)

### Step 1: Open Shortcuts App

1. Press `Cmd+Space` and type "Shortcuts"
2. Click **Shortcuts.app** to open it

### Step 2: Create New Shortcut

1. Click the **+** button in the top toolbar
2. In the search bar on the right, type "Run Shell Script"
3. Drag **"Run Shell Script"** into your workflow

### Step 3: Configure the Shell Script

1. Set **Shell** to: `/bin/zsh`
2. Set **Pass input** to: `as arguments` (or leave default)
3. In the script text box, paste:

   ```bash
   open -a /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot.app
   ```

   _(Replace `/Users/aniruddh` with your actual home directory if different)_

   **Note:** We use the native app instead of the shell script because Shortcuts runs in the background without GUI access, which prevents `screencapture -i` from showing the selection UI.

### Step 4: Name and Save

1. Click the **details** icon (info icon, top right)
2. Name it: **"OCR Screenshot"**
3. Click **Done**

### Step 5: Assign Keyboard Shortcut

1. Right-click your new shortcut in the sidebar
2. Select **"Add Keyboard Shortcut"** or click the **(i)** icon → **Keyboard Shortcut**
3. Press **Command+Shift+3**
4. If macOS warns about conflicts, proceed to Step 6

### Step 6: Disable Default Screenshot Shortcut (if needed)

1. Open **System Settings** (or System Preferences)
2. Go to **Keyboard** → **Keyboard Shortcuts**
3. Select **Screenshots** in the left sidebar
4. Find **"Save picture of screen as a file"** (usually Cmd+Shift+3)
5. **Uncheck** it or change it to a different key combo
6. Close System Settings
7. Return to Shortcuts and reassign **Command+Shift+3** to your OCR shortcut

---

## Option 2: Automator Quick Action (macOS Catalina/Big Sur)

### Step 1: Open Automator

1. Press `Cmd+Space` and type "Automator"
2. Click **Automator.app**

### Step 2: Create Quick Action

1. Choose **"Quick Action"** (or "Service" on older macOS)
2. Click **Choose**

### Step 3: Configure Workflow

1. Set **"Workflow receives"** to: **no input**
2. Set **"in"** to: **any application**
3. In the search box (left side), type "Run Shell Script"
4. Drag **"Run Shell Script"** into the workflow area on the right

### Step 4: Configure Shell Script

1. Set **Shell** to: `/bin/zsh`
2. Set **Pass input** to: `as arguments`
3. Paste this in the script box:

   ```bash
   open -a /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot.app
   ```

   **Note:** We use the native app instead of the shell script because Automator runs in the background without GUI access, which prevents `screencapture -i` from showing the selection UI.

### Step 5: Save

1. Press `Cmd+S`
2. Name it: **"OCR Screenshot"**
3. Close Automator

### Step 6: Assign Keyboard Shortcut

1. Open **System Settings** (or System Preferences)
2. Go to **Keyboard** → **Keyboard Shortcuts** → **Services**
3. Scroll down to **General** section
4. Find **"OCR Screenshot"**
5. Click on it and press **Command+Shift+3**
6. If there's a conflict, first disable the default screenshot shortcut (see Option 1, Step 6)

---

## Option 3: Manual Script Path (for Advanced Users)

If you prefer to keep the absolute path flexible, create a symlink:

```bash
sudo ln -sf /Users/aniruddh/projects/screenshotwithocr/scripts/ocrshot /usr/local/bin/ocrshot
```

Then in your Shortcut/Automator script, just use:

```bash
ocrshot
```

---

## Testing Your Shortcut

1. Press **Command+Shift+3**
2. Your cursor should turn into a crosshair
3. Click and drag to select a text region
4. Release the mouse button
5. After 1-2 seconds, a notification appears: **"OCR complete — text copied to clipboard"**
6. TextEdit opens with the recognized text (unless you use `--no-open` flag)

---

## Troubleshooting

### Shortcut doesn't trigger

- Make sure you've **disabled or reassigned** the default macOS screenshot shortcut
- Try a different key combo like **Control+Option+Command+3** if conflicts persist
- Restart your Mac after changing System Settings

### "Permission denied" or "Command not found"

- Ensure the script is executable:
  ```bash
  chmod +x /Users/aniruddh/projects/screenshotwithocr/scripts/ocrshot
  ```
- Rebuild binaries:
  ```bash
  cd /Users/aniruddh/projects/screenshotwithocr
  ./build.sh
  ```

### No text detected

- Vision OCR works best on clear, printed text
- Try selecting a larger region with higher contrast
- If Vision fails, the script automatically tries Tesseract (if installed)

### Notification doesn't appear

- Check that notifications are enabled for "Script Editor" or "Shortcuts" in System Settings → Notifications

---

## Uninstalling

To remove the keyboard shortcut:

1. Open Shortcuts (or System Settings → Keyboard → Shortcuts → Services)
2. Find "OCR Screenshot"
3. Delete it or remove the keyboard shortcut binding
