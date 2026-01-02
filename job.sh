#!/bin/bash
set -uo pipefail
trap "kill 0" EXIT # kill all subprocesses (rclone) on exit

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REMOTE_DIR="Rclone"
RCLONE_REMOTE_NAME="rclone"
REMOTE_PATH="$RCLONE_REMOTE_NAME:$REMOTE_DIR"
EXCLUDE_FILE="$SCRIPT_DIR/excludes.txt"
LOG_FILE="/tmp/rclone-job.log"
LOCK_FILE="/tmp/rclone-job.lock"
source "$SCRIPT_DIR/paths.sh"

# lock file handling
exec 200> "$LOCK_FILE"
if ! flock -n 200; then
  echo -e "\033[31mAnother instance of the script is running. Exiting.\033[0m"
  exit 1
fi

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
  if [ $1 -eq 0 ]; then
    echo "$2 completed successfully ✅"
  else
    echo "$2 did not complete successfully ❌"
    echo "exit code : $1"
  fi
}
function print_header {
  printf '\n'; printf '=%.0s' {1..20}; printf "[$1]"; printf '=%.0s' {1..20}; printf '\n'
}

# syncs
echo -e "\033[32mStarting syncs...\033[0m"
for dir in "${!syncs[@]}"; do
  print_header "$dir" && print_header "$dir" >> "$LOG_FILE"

  if [ ! -d $dir ]; then
    echo "The directory '$dir'"
    echo "Cound not be found, skipping ⏩"
    continue
  fi

  rclone sync "${syncs[$dir]}" "$REMOTE_PATH/$dir" "${RCLONE_FLAGS[@]}"
  print_status $? "$dir"
done

# backups
echo "Starting backups..."
for dir in "${!backups[@]}"; do
  print_header "$dir" && print_header "$dir" >> "$LOG_FILE"

  if [ ! -d $dir ]; then
    echo "The directory '$dir'"
    echo "Cound not be found, skipping ⏩"
    continue
  fi

  rclone copy "${backups[$dir]}" "$REMOTE_PATH/$dir" "${RCLONE_FLAGS[@]}"
  print_status
done
