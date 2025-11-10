# Setting Up Keyboard Shortcut for OCR Screenshot

This guide will help you bind a keyboard shortcut (recommended: **Command+Shift+2** or **Control+Option+Command+3**) to instantly trigger OCR on any selected screen region.

**Note:** Command+Shift+3 is reserved by macOS for screenshots and cannot be reassigned in Shortcuts app on some macOS versions. Use Command+Shift+2 or another combo instead.

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
   /Users/aniruddh/projects/screenshotwithocr/run_ocr_shortcut.sh
   ```

   _(Replace `/Users/aniruddh` with your actual home directory if different)_

   **Important:** This wrapper script uses AppleScript to run screencapture with proper GUI permissions.

### Step 4: Name and Save

1. Click the **details** icon (info icon, top right)
2. Name it: **"OCR Screenshot"**
3. Click **Done**

### Step 5: Assign Keyboard Shortcut

1. Right-click your new shortcut in the sidebar
2. Select **"Add Keyboard Shortcut"** or click the **(i)** icon → **Keyboard Shortcut**
3. Press **Command+Shift+2** (or another key combo like Control+Option+Command+3)
   - **Don't use Cmd+Shift+3** - macOS reserves it for screenshots and won't let you reassign it in Shortcuts
4. If macOS warns about conflicts, try a different combo

### Step 6: Enable Required Permissions

For the shortcut to work in all apps (including WhatsApp):

1. Open **System Settings** → **Privacy & Security**
2. Go to **Automation**:
   - Enable **Shortcuts** → **System Events**
3. Go to **Accessibility**:
   - Add and enable **Shortcuts**
4. Go to **Screen Recording**:
   - Add and enable **Shortcuts** (this allows it to trigger screencapture)

**Important:** After enabling these permissions, quit and reopen any apps (like WhatsApp) for the shortcut to work in them.

---

## Option 2: Automator Quick Action (RECOMMENDED for WhatsApp/Electron apps)

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
   /Users/aniruddh/projects/screenshotwithocr/run_ocr_shortcut.sh
   ```

   **Important:** This wrapper script uses AppleScript to run screencapture with proper GUI permissions.

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

- **Can't use Cmd+Shift+3?** macOS reserves it for screenshots. Use **Cmd+Shift+2** or **Ctrl+Opt+Cmd+3** instead
- Check permissions (see Step 6 above): Shortcuts needs Automation, Accessibility, and Screen Recording access
- Restart your Mac after changing permissions

### Shortcut doesn't work in specific apps (WhatsApp, Slack, etc.)

1. Go to **System Settings** → **Privacy & Security** → **Screen Recording**
2. Make sure **Shortcuts** is enabled
3. **Quit and reopen** the problematic app (WhatsApp, etc.)
4. If still not working, add **System Events** to Screen Recording permissions as well
5. Some apps may override keyboard shortcuts - try a different key combo

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
