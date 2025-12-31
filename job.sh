#!/bin/bash
set -uo pipefail
source ./paths.sh

REMOTE_DIR="Rclone"
RCLONE_REMOTE_NAME="rclone"
REMOTE_PATH="$RCLONE_REMOTE_NAME:$REMOTE_DIR"
EXCLUDE_FILE="excludes.txt"
LOG_FILE="$XDG_RUNTIME_DIR/rclone-job.log"
LOCK_FILE="$XDG_RUNTIME_DIR/rclone-job.lock"

# this line clears the logs, and creates it if not exists!
> "$LOG_FILE"

if [ ! -f "$EXCLUDE_FILE" ]; then
  echo "Exclude file $EXCLUDE_FILE not found!"
  exit 1
fi

# I got options from https://forum.rclone.org/t/what-is-the-impact-of-use-mmap-besides-reducing-memory-usage/40677
# and https://www.reddit.com/r/backblaze/comments/ykx3y6/optimal_transfer_parameter_for_rclone/
RCLONE_FLAGS=(
  --transfers 8
  --checkers 16
  --use-mmap
  --order-by size,mixed,75
  --max-backlog 1000
  --log-file "$LOG_FILE"
  --log-level INFO
  --exclude-from "$EXCLUDE_FILE"
)

function print_status {
  if [ $? -eq 0 ]; then
    echo "completed successfully ✅"
  else
    echo "something went wrong ❌"
  fi
}
function print_header {
  printf '\n'; printf '=%.0s' {1..20}; printf "[$dir]"; printf '=%.0s' {1..20}; printf '\n' >> "$LOG_FILE"
}

# lock file handling
exec 200> "$LOCK_FILE"
if ! flock -n 200; then
  echo "Another instance of the script is running. Exiting."
  exit 1
fi

# syncs
echo "Starting syncs..."
for dir in "${!syncs[@]}"; do
  print_header && print_header >> "$LOG_FILE"
  rclone sync "${syncs[$dir]}" "$REMOTE_PATH/$dir" "${RCLONE_FLAGS[@]}"
  print_status
done

# backups
echo "Starting backups..."
for dir in "${!backups[@]}"; do
  rclone copy "${backups[$dir]}" "$REMOTE_PATH/$dir" "${RCLONE_FLAGS[@]}"
  print_status
done
