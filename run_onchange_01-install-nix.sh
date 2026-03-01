#!/bin/bash

# run_before_onchange_install-nix.sh
# Installs Nix using Determinate Systems installer if it's not already installed.
# This script runs before everything else in chezmoi.

LOG_DIR="$HOME/.config/personalScripts/logs"
LOG_FILE="$LOG_DIR/run_onchange_01-install-nix.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if ! command -v nix >/dev/null 2>&1; then
    log_message "Nix not found. Installing Nix with Determinate Systems installer..."
    # Attempt to install Nix
    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm; then
        log_message "SUCCESS: Nix installation completed successfully."
    else
        log_message "ERROR: Nix installation failed."
        exit 1
    fi
else
    log_message "INFO: Nix is already installed."
fi
