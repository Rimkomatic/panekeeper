#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SESSIONS_DIR="$HOME/.project-sessions"
NVIM_SESSIONS_DIR="$HOME/.local/state/nvim/sessions"

RESURRECT_DIR="$CURRENT_DIR/helpers/scripts"

mkdir -p "$TMUX_SESSIONS_DIR" "$NVIM_SESSIONS_DIR"

# ---------------------------------------------------------
# Core Functions
# ---------------------------------------------------------

get_sessions() {
    if [ -d "$TMUX_SESSIONS_DIR" ]; then
        find "$TMUX_SESSIONS_DIR" -maxdepth 1 -name "*.txt" ! -name "tmux_resurrect_*.txt" -type f -exec basename {} .txt \; | sort
    fi
}

in_tmux() {
    [ -n "$TMUX" ]
}

do_list() {
    get_sessions
}

do_load() {
    local TARGET="$1"
    
    if [ -z "$TARGET" ]; then
        echo "Error: No session name provided."
        echo "Usage: $0 load <session_name>"
        return 1
    fi

    if tmux has-session -t "$TARGET" 2>/dev/null; then
        echo "Session '$TARGET' is already running. Attaching..."
        if in_tmux; then
            tmux switch-client -t "$TARGET"
        else
            tmux attach-session -t "$TARGET"
        fi
    else
        echo "Restoring session '$TARGET' from backup..."
        tmux new-session -d -s "dummy_restore" 2>/dev/null
        
        ln -sf "$TMUX_SESSIONS_DIR/${TARGET}.txt" "$TMUX_SESSIONS_DIR/last"
        
        tmux run-shell "$RESURRECT_DIR/restore.sh"
        
        sleep 2.5
        
        if tmux has-session -t "$TARGET" 2>/dev/null; then
            tmux kill-session -t "dummy_restore" 2>/dev/null
            
            echo "Loading Neovim states..."
            # Find all panes in this newly restored session that are running nvim
            tmux list-panes -s -t "$TARGET" -F '#{pane_id} #{pane_current_command}' |
            grep ' nvim$' | cut -d' ' -f1 |
            while read -r pane; do
                tmux send-keys -t "$pane" Escape
                tmux send-keys -t "$pane" ":TmuxSessionLoad" Enter
            done
            
            if in_tmux; then
                tmux switch-client -t "$TARGET"
            else
                tmux attach-session -t "$TARGET"
            fi
        else
            echo "Error: Tmux-resurrect failed to build the session '$TARGET'."
            echo "Make sure your save file isn't empty and that @resurrect-dir is set."
        fi
    fi
}

do_save() {
    local TARGET_NAME="$1"

    if [ -z "$TARGET_NAME" ]; then
        TARGET_NAME=$(tmux display-message -p '#S' 2>/dev/null | tr -d '\n')
    fi

    if [ -z "$TARGET_NAME" ]; then
        return 1
    fi

    local SESSIONS_DIR="$TMUX_SESSIONS_DIR"
    local RESURRECT_SCRIPT="$RESURRECT_DIR/save.sh"

    mkdir -p "$SESSIONS_DIR"

    tmux run-shell -t "$TARGET_NAME" "$RESURRECT_SCRIPT" >/dev/null 2>&1
    
    if [ -f "$SESSIONS_DIR/last" ] || [ -L "$SESSIONS_DIR/last" ]; then
        cp -L "$SESSIONS_DIR/last" "$SESSIONS_DIR/${TARGET_NAME}.txt"
        ln -sf "$SESSIONS_DIR/${TARGET_NAME}.txt" "$SESSIONS_DIR/last"
        rm -f "$SESSIONS_DIR"/tmux_resurrect_*.txt
    fi
}

do_create() {
    local NEW_NAME="$1"
    
    if [ -z "$NEW_NAME" ]; then
        echo "Error: No project name provided."
        echo "Usage: $0 new <session_name>"
        return 1
    fi

    if tmux has-session -t "$NEW_NAME" 2>/dev/null; then
        echo "A session with the name '$NEW_NAME' already exists."
        return 1
    fi

    if in_tmux; then
        tmux new-session -d -s "$NEW_NAME"
        tmux switch-client -t "$NEW_NAME"
    else
        tmux new-session -s "$NEW_NAME"
    fi
}

do_delete() {
    local TARGET="$1"
    
    if [ -z "$TARGET" ]; then
        echo "Error: No session name provided."
        echo "Usage: $0 delete <session_name>"
        return 1
    fi

    local TMUX_FILE="$TMUX_SESSIONS_DIR/${TARGET}.txt"
    local DELETED=0

    if [ -f "$TMUX_FILE" ]; then
        rm "$TMUX_FILE"
        echo "Deleted Tmux file: $TARGET.txt"
        DELETED=1
    fi

   local NVIM_SESSIONS_DIR="$HOME/.local/state/nvim/sessions"
    if [ -d "$NVIM_SESSIONS_DIR" ]; then
        find "$NVIM_SESSIONS_DIR" -type f -name "${TARGET}_*" -delete
    fi
    # -----------------------------------------

    tmux kill-session -t "$TARGET" 2>/dev/null
    echo "Deleted project '$TARGET'."
}

# ---------------------------------------------------------
# Argument Routing
# ---------------------------------------------------------

COMMAND="$1"
ARG="$2"

case "$COMMAND" in
    list)
        do_list
        ;;
    load|enter)
        do_load "$ARG"
        ;;
    new|create)
        do_create "$ARG"
        ;;
    save)
        do_save "$ARG"
        ;;
    delete|rm)
        do_delete "$ARG"
        ;;
    *)
        echo "Tmux Project Manager"
        echo "Usage: $0 {list | load <name> | new <name> | save [name] | delete <name>}"
        exit 1
        ;;
esac
