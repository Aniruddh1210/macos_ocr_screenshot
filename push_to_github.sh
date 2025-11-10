#!/usr/bin/env bash
# Helper script to push this project to GitHub
# Run this after you've created an empty repo on GitHub

set -euo pipefail

echo "=================================================="
echo "GitHub Setup Helper"
echo "=================================================="
echo ""
echo "Before running this script, create a new repository on GitHub:"
echo "  1. Go to https://github.com/new"
echo "  2. Create a new repository (e.g., 'screenshotwithocr')"
echo "  3. Do NOT initialize with README, .gitignore, or license (we already have them)"
echo "  4. Copy the repository URL"
echo ""
read -p "Enter your GitHub repository URL (e.g., https://github.com/username/screenshotwithocr.git): " REPO_URL

if [ -z "$REPO_URL" ]; then
  echo "No URL provided. Exiting."
  exit 1
fi

echo ""
echo "Setting remote origin to: $REPO_URL"
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "=================================================="
echo "✅ Successfully pushed to GitHub!"
echo "=================================================="
echo ""
echo "Your repository is now available at:"
echo "  ${REPO_URL%.git}"
echo ""
echo "Next steps:"
echo "  - Set up Command+Shift+3: see SETUP_KEYBOARD_SHORTCUT.md"
echo "  - Share your repo or star it for visibility"
echo ""
