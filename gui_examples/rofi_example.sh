#!/usr/bin/env bash

# ==============================================================================
# USER CONFIGURATION
# ==============================================================================
MANAGER_SCRIPT="$HOME/.config/panekeeper/bin/manage-project.sh"

# Basic dmenu mode configuration with an optional prompt layout
LAUNCHER_CMD="rofi -dmenu -p Panekeeper"

# Define your terminal emulator execution string here
TERMINAL_CMD="wezterm start --always-new-process --"
# ==============================================================================

OPTIONS="Load Project\nNew Project\nDelete Project"

CHOICE=$(echo -e "$OPTIONS" | $LAUNCHER_CMD)

case "$CHOICE" in
    "Load Project")
        SESSIONS=$("$MANAGER_SCRIPT" list)
        
        if [ -z "$SESSIONS" ]; then
            echo "No saved projects found." | $LAUNCHER_CMD
            exit 0
        fi
        
        TARGET=$(echo "$SESSIONS" | $LAUNCHER_CMD)
        
        if [ -n "$TARGET" ]; then
            $TERMINAL_CMD "$MANAGER_SCRIPT" load "$TARGET"
        fi
        ;;
        
    "New Project")
        TARGET=$(echo "" | $LAUNCHER_CMD)
        
        if [ -n "$TARGET" ]; then
            $TERMINAL_CMD "$MANAGER_SCRIPT" new "$TARGET"
        fi
        ;;
        
    "Delete Project")
        SESSIONS=$("$MANAGER_SCRIPT" list)
        
        if [ -z "$SESSIONS" ]; then
            echo "No saved projects found." | $LAUNCHER_CMD
            exit 0
        fi
        
        TARGET=$(echo "$SESSIONS" | $LAUNCHER_CMD)
        
        if [ -n "$TARGET" ]; then
            CONFIRM=$(echo -e "Yes\nNo" | $LAUNCHER_CMD)
            
            if [ "$CONFIRM" = "Yes" ]; then
                "$MANAGER_SCRIPT" delete "$TARGET"
                echo "Successfully deleted '$TARGET'" | $LAUNCHER_CMD
            fi
        fi
        ;;
esac
