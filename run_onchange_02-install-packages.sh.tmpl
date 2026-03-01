#!/bin/bash

# run_onchange_install-packages.sh
# Installs or updates Nix packages defined in ~/.config/nix/flake.nix
# This script is triggered whenever the flake.nix file changes.
# hash: {{ include "dot_config/nix/flake.nix" | sha256sum }}

LOG_DIR="$HOME/.config/personalScripts/02-InstallPackages"
LOG_FILE="$LOG_DIR/InstallPackages.log"
FLAKE_DIR="$HOME/.config/nix"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if ! command -v nix >/dev/null 2>&1; then
    log_message "ERROR: Nix is not installed. Skipping package installation."
    exit 1
fi

log_message "INFO: Updating/Installing packages from $FLAKE_DIR..."

# We use 'nix profile install' or 'nix profile upgrade'
# Since we want to ensure everything in the flake is present, we can use:
if nix profile install "$FLAKE_DIR" --extra-experimental-features "nix-command flakes" --accept-flake-config; then
    log_message "SUCCESS: Packages updated/installed successfully."
else
    # If already installed, try upgrading
    log_message "INFO: 'nix profile install' failed or already exists, attempting 'nix profile upgrade'..."
    if nix profile upgrade 0 --extra-experimental-features "nix-command flakes"; then
        log_message "SUCCESS: Packages upgraded successfully."
    else
        log_message "ERROR: Failed to update/install packages from flake."
        exit 1
    fi
fi
