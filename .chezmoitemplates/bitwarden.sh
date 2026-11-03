# Shared Bitwarden helpers for the Linux run scripts. Include after common.sh.
# bitwarden_unlock prompts once; bitwarden_lock relocks only what it unlocked.
BW_LOCKED_BY_SCRIPT=false

# Reads a secret from the terminal into REPLY, echoing * for each character.
read_masked() {
  local char

  REPLY=""
  printf '%s' "$1" >/dev/tty
  while IFS= read -r -s -n 1 char </dev/tty; do
    [ -z "$char" ] && break
    if [ "$char" = $'\x7f' ] || [ "$char" = $'\b' ]; then
      if [ -n "$REPLY" ]; then
        REPLY="${REPLY%?}"
        printf '\b \b' >/dev/tty
      fi
      continue
    fi
    REPLY+="$char"
    printf '*' >/dev/tty
  done
  printf '\n' >/dev/tty
}

# Runs a bw command that needs the master password, allowing three attempts.
# The password is passed via --passwordenv so it never appears in the process list.
bw_with_password() {
  local attempt

  for attempt in 1 2 3; do
    read_masked "Bitwarden master password: "
    if BW_SESSION="$(BW_PASSWORD="$REPLY" bw "$@" --passwordenv BW_PASSWORD --raw)"; then
      REPLY=""
      return 0
    fi
    REPLY=""
    log_message "INFO: Bitwarden rejected the password (attempt $attempt of 3)."
  done

  return 1
}

# Logs in to or unlocks Bitwarden on the given server and exports BW_SESSION.
# Reuses an already unlocked BW_SESSION from the environment.
bitwarden_unlock() {
  local server="$1" status bw_email

  status="$(bw status 2>/dev/null)"

  if [ -n "${BW_SESSION:-}" ] && echo "$status" | grep -q '"status":"unlocked"'; then
    log_message "INFO: Using the unlocked Bitwarden session from BW_SESSION."
  elif [ ! -t 0 ]; then
    log_message "ERROR: Bitwarden is not unlocked and there is no terminal to prompt in. Export BW_SESSION and re-run chezmoi apply."
    return 1
  elif echo "$status" | grep -q '"status":"unauthenticated"'; then
    if ! echo "$status" | grep -q "\"serverUrl\":\"$server\""; then
      bw config server "$server" >/dev/null
    fi

    log_message "INFO: Logging in to Bitwarden at $server."
    read -r -p "Bitwarden email: " bw_email </dev/tty
    if ! bw_with_password login "$bw_email"; then
      log_message "ERROR: Bitwarden login failed."
      return 1
    fi
    BW_LOCKED_BY_SCRIPT=true
  else
    log_message "INFO: Unlocking Bitwarden."
    if ! bw_with_password unlock; then
      log_message "ERROR: Bitwarden unlock failed."
      return 1
    fi
    BW_LOCKED_BY_SCRIPT=true
  fi

  export BW_SESSION
  bw sync >/dev/null 2>&1 || log_message "INFO: Bitwarden sync failed; using the cached vault."
}

# Prints the password field of a Bitwarden item; empty if it does not exist.
bitwarden_password() {
  bw get password "$1" 2>/dev/null
}

# Prints a Bitwarden item as JSON; empty if it does not exist.
bitwarden_item() {
  bw get item "$1" 2>/dev/null
}

bitwarden_lock() {
  if [ "$BW_LOCKED_BY_SCRIPT" = true ]; then
    bw lock >/dev/null 2>&1
    unset BW_SESSION
    BW_LOCKED_BY_SCRIPT=false
  fi
}
