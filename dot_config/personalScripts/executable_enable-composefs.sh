#!/bin/sh
set -eu

LOG_DIR="$HOME/.config/personalScripts/logs"
LOG_FILE="$LOG_DIR/enable-composefs.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

is_ostree() {
    [ -d /sys/fs/ostree ] || [ -f /run/ostree-booted ]
}

main() {
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
    cat <<EOF | sudo tee /etc/ostree/prepare-root.conf > /dev/null
[composefs]
enabled = yes

[root]
transient = true
EOF

    log_message "Configuring rpm-ostree to track the file in the initramfs and rebooting..."
    sudo rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf
}

main "$@"
