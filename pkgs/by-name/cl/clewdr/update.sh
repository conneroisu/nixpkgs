#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

PACKAGE_NAME="clewdr"
OWNER="Xerxes-2"
REPO="clewdr"

# Get the latest release from GitHub API
LATEST=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest")
LATEST_VERSION=$(echo "$LATEST" | jq -r '.tag_name' | sed 's/^v//')

echo "Latest version: $LATEST_VERSION"

# Update the version and hash
update-source-version "$PACKAGE_NAME" "$LATEST_VERSION"

echo "Updated $PACKAGE_NAME to version $LATEST_VERSION"