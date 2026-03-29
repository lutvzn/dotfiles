#!/bin/bash

set -u

LOG_DIR="$HOME/.config/personalScripts/logs"
LOG_FILE="$LOG_DIR/update-flake-lock.log"
DEFAULT_CHEZMOI_SOURCE_DIR="$HOME/.local/share/chezmoi"

mkdir -p "$LOG_DIR"

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

if ! command -v nix >/dev/null 2>&1; then
  log_message "ERROR: Nix is not installed."
  exit 1
fi

if command -v chezmoi >/dev/null 2>&1; then
  CHEZMOI_SOURCE_DIR="$(chezmoi source-path)"
else
  CHEZMOI_SOURCE_DIR="$DEFAULT_CHEZMOI_SOURCE_DIR"
fi

FLAKE_DIR="$CHEZMOI_SOURCE_DIR/dot_config/nix"

if [ ! -d "$FLAKE_DIR" ]; then
  log_message "ERROR: Flake directory not found at $FLAKE_DIR."
  exit 1
fi

cd "$CHEZMOI_SOURCE_DIR" || exit 1

log_message "Updating flake.lock in $FLAKE_DIR..."
if nix flake update --flake "$FLAKE_DIR"; then
  log_message "SUCCESS: flake.lock updated successfully."
else
  log_message "ERROR: Failed to update flake.lock."
  exit 1
fi
