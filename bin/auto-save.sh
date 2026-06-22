#!/usr/bin/env bash

INTERVAL_MINS="${1:-1}"
INTERVAL_SECS=$((INTERVAL_MINS * 60))

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER_SCRIPT="$CURRENT_DIR/manage-project.sh"

# Kill older autosave daemons
for pid in $(pgrep -f "auto-save.sh"); do
    if [ "$pid" != "$$" ]; then
        kill "$pid" 2>/dev/null
    fi
done

while true; do
    sleep "$INTERVAL_SECS"

    if ! tmux info &>/dev/null; then
        exit 0
    fi

    tmux list-clients -F '#{session_name}' | sort -u | while read -r SESSION; do

        tmux set-option -g @is_saving "1"
        tmux refresh-client -S

        "$MANAGER_SCRIPT" save "$SESSION"

        tmux set-option -ug @is_saving
        tmux refresh-client -S
    done
done
