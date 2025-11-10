#!/usr/bin/env bash
# Wrapper script for keyboard shortcut - uses osascript to run with GUI permissions
set -e

# Use osascript to run screencapture with proper GUI context, then OCR
osascript <<'EOF'
tell application "System Events"
    set tmpPath to (POSIX path of (path to temporary items)) & "ocrshot_" & (do shell script "uuidgen") & ".png"
    do shell script "/usr/sbin/screencapture -i -x " & quoted form of tmpPath
    
    if (do shell script "test -f " & quoted form of tmpPath & " && echo yes || echo no") is "yes" then
        -- Run OCR with --no-open flag so it only copies to clipboard
        do shell script "/Users/aniruddh/projects/screenshotwithocr/scripts/ocrshot --input " & quoted form of tmpPath & " --no-open 2>&1"
    end if
end tell
EOF
