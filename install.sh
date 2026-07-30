#!/bin/sh
set -eu

# Remote installer for jellyfin-clean-orphans.
# Downloads the script directly from GitHub (raw) and installs it globally.
# No git required on the target machine.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/bajzarpa/jellyclean/main/install.sh | sudo sh

REPO="bajzarpa/jellyclean"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/bin/jellyfin-clean-orphans"
DEST="/usr/local/bin/jellyfin-clean-orphans"

if [ "$(id -u)" -ne 0 ]; then
    echo "This installer needs root (to write to /usr/local/bin)."
    echo "Re-run as: curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | sudo sh"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "WARNING: python3 not found on this system. The command needs python3 to run."
fi

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$DEST"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$DEST" "$RAW_URL"
else
    echo "ERROR: neither curl nor wget found. Install one of them first."
    exit 1
fi

chmod +x "$DEST"

echo "Installed: $DEST"
echo ""
echo "Try it out:"
echo "  jellyfin-clean-orphans --image-gap-report"
echo "  jellyfin-clean-orphans --all --dry-run"
echo ""
echo "To update later, just re-run this same install command."
echo "To uninstall:"
echo "  sudo rm $DEST"
