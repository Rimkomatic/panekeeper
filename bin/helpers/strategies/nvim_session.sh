#!/usr/bin/env bash

ORIGINAL_COMMAND="$1"
DIRECTORY="$2"

# We unconditionally tell tmux to launch Neovim and instantly run our custom Lua command
echo "$ORIGINAL_COMMAND -c 'TmuxSessionLoad'"
