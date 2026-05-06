#!/bin/sh
set -eu

LOG_DIR="$HOME/.config/personalScripts/logs"
LOG_FILE="$LOG_DIR/enable-composefs.log"
PRIVILEGED_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

run_as_root() {
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

    log_message "sudo or run0 is required to enable composefs."
    exit 1
}

is_ostree() {
    [ -d /sys/fs/ostree ] || [ -f /run/ostree-booted ]
}

main() {
    temp_config=""

    if ! is_ostree; then
        log_message "This system is not an OSTree-based system. Exiting."
        exit 0
    fi

    # Check if the configuration already exists
    if [ -f /etc/ostree/prepare-root.conf ] && \
       grep -q "\[composefs\]" /etc/ostree/prepare-root.conf && \
       grep -q "enabled = yes" /etc/ostree/prepare-root.conf && \
       grep -q "\[root\]" /etc/ostree/prepare-root.conf && \
       grep -q "transient = true" /etc/ostree/prepare-root.conf; then
        log_message "/etc/ostree/prepare-root.conf is already configured. No changes needed."
        exit 0
    fi

    # Configuration to enable composefs and set the root to transient
    log_message "Updating /etc/ostree/prepare-root.conf..."
    temp_config="$(mktemp "${TMPDIR:-/tmp}/prepare-root.conf.XXXXXX")"
    trap 'rm -f "$temp_config"' EXIT HUP INT TERM

    cat > "$temp_config" <<EOF
[composefs]
enabled = yes

[root]
transient = true
EOF
    run_as_root install -m 0644 "$temp_config" /etc/ostree/prepare-root.conf

    log_message "Configuring rpm-ostree to track the file in the initramfs and rebooting..."
    run_as_root rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf
}

main "$@"
