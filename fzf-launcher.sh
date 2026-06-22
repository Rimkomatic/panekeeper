#!/usr/bin/env bash

# ==============================================================================
# USER CONFIGURATION
# ==============================================================================
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MANAGER_SCRIPT="$CURRENT_DIR/bin/manage-project.sh"
# ==============================================================================

if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is required for this launcher."
    exit 1
fi

echo -e "\n=== Workspace Orchestrator ==="
CHOICE=$(printf "Load Project\nNew Project\nDelete Project" | eval fzf $FZF_OPTIONS --header="'Select Action'")

case "$CHOICE" in
    "Load Project")
        SESSIONS=$("$MANAGER_SCRIPT" list)
        if [ -z "$SESSIONS" ]; then
            echo "No saved projects found."
            exit 0
        fi

        TARGET=$(echo "$SESSIONS" | eval fzf $FZF_OPTIONS --header="'Load Project'")

        if [ -n "$TARGET" ]; then
            # Running directly to respect your old core engine's attachment logic
            "$MANAGER_SCRIPT" load "$TARGET"
        fi
        ;;

    "New Project")
        echo -n "Enter New Project Name: "
        read -r TARGET
        if [ -n "$TARGET" ]; then
            "$MANAGER_SCRIPT" new "$TARGET"
        fi
        ;;

    "Delete Project")
        SESSIONS=$("$MANAGER_SCRIPT" list)
        if [ -z "$SESSIONS" ]; then
            echo "No saved projects found."
            exit 0
        fi

        TARGET=$(echo "$SESSIONS" | eval fzf $FZF_OPTIONS --header="'Delete Project'")

        if [ -n "$TARGET" ]; then
            echo -n "Are you sure you want to delete '$TARGET'? (y/n): "
            read -r CONFIRM
            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                "$MANAGER_SCRIPT" delete "$TARGET"
            fi
        fi
        ;;
esac
