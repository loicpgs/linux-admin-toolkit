#!/bin/bash

LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/system_update.log"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run with sudo or as root."
        exit 1
    fi
}

run_step() {
    STEP_NAME="$1"
    COMMAND="$2"

    log "START - $STEP_NAME"

    if eval "$COMMAND" >> "$LOG_FILE" 2>&1; then
        log "SUCCESS - $STEP_NAME"
    else
        log "ERROR - $STEP_NAME"
        exit 1
    fi
}

log "=============================="
log "Linux system update started"
log "=============================="

check_root

run_step "Updating package list" "apt update"
run_step "Upgrading installed packages" "apt upgrade -y"
run_step "Removing unnecessary packages" "apt autoremove -y"
run_step "Cleaning package cache" "apt autoclean -y"

log "=============================="
log "Linux system update completed"
log "Log file: $LOG_FILE"
log "=============================="
