# Shared helpers for the Linux run scripts. Set LOG_FILE after including.
LOG_DIR="${ORIG_HOME:-$HOME}/.config/personalScripts/logs"
PRIVILEGED_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

mkdir -p "$LOG_DIR"

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

source_brew_environment() {
  local brew_bin

  for brew_bin in \
    "/home/linuxbrew/.linuxbrew/bin/brew" \
    "/opt/homebrew/bin/brew" \
    "/usr/local/bin/brew"; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done

  return 1
}

run_with_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return
  fi

  if command -v run0 >/dev/null 2>&1; then
    run0 /usr/bin/env "PATH=$PRIVILEGED_PATH" "$@"
    return
  fi

  log_message "ERROR: sudo or run0 is required to run $1."
  exit 1
}
