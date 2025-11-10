-- AppleScript helper to run the OCR screenshot script
-- Use this in Automator (Run AppleScript) or compile into an app and assign a keyboard shortcut
on run {}
    -- Adjust the path below if you moved the project
    set scriptPath to "/Users/aniruddh/projects/screenshotwithocr/scripts/ocr_screenshot.sh"
    -- Run the script in background so Automator doesn't block while the user selects
    do shell script quoted form of scriptPath & " &>/tmp/ocr_shortcut.log &"
    open /Users/aniruddh/projects/screenshotwithocr/OCRScreenshot.app
    return "Started OCR script"
end run
