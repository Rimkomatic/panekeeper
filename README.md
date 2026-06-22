# Panekeeper

> A robust, background-driven workspace orchestrator that bridges the gap between Tmux and Neovim.

If you use Tmux and Neovim, you've probably encountered the same problem: Tmux can restore windows and pane layouts, but Neovim reopens with none of your buffers, cursor positions, or editing context.

**Panekeeper** solves this by keeping your Tmux layout and Neovim state synchronized. Save, restore, and manage entire development environments without losing your workspace.

---

## Features

* Restore complete Tmux workspaces
* Restore Neovim buffers, folds, and cursor positions
* Automatic background snapshots
* Pane-aware Neovim session management
* Project-based workspace organization
* Fast FZF-powered project launcher
* Crash and reboot recovery
* Lightweight, decoupled architecture

---

## Architecture

Panekeeper consists of four independent components:

### Tmux Engine

A customized, headless implementation of `tmux-resurrect` that manages:

* Sessions
* Windows
* Pane layouts
* Working directories

### Neovim Engine

A Lua module built on top of `mini.sessions` that automatically snapshots:

* Open buffers
* Cursor locations
* Window state
* Folds

Snapshots are updated whenever editing activity stops.

### Bridge Layer

When a project is loaded, Panekeeper:

1. Restores the Tmux layout.
2. Locates panes running Neovim.
3. Injects pane-specific restore commands.
4. Rehydrates the exact Neovim state for each pane.

### Auto-Save Daemon

A silent background process periodically snapshots the entire workspace.

This ensures that unexpected crashes, reboots, or terminal closures do not result in lost work.

---

# Installation

## 1. Clone the Repository

Clone Panekeeper into your configuration directory:

```bash
git clone https://github.com/YOUR_USERNAME/panekeeper.git ~/.config/panekeeper
```

Make the scripts executable:

```bash
chmod +x ~/.config/panekeeper/bin/*.sh
chmod +x ~/.config/panekeeper/bin/helpers/scripts/*.sh
chmod +x ~/.config/panekeeper/fzf-launcher.sh
```

---

## 2. Configure Tmux

Add the following to your `~/.tmux.conf`:

```tmux
# Start the auto-save daemon (every 10 minutes)
run-shell -b "~/.config/panekeeper/bin/auto-save.sh 10"

# Save the current project manually
bind-key W run-shell -b "~/.config/panekeeper/bin/manage-project.sh save '#S'"

# Open the Panekeeper project manager
bind-key P display-popup -E "~/.config/panekeeper/fzf-launcher.sh"

# Optional status bar indicator
# Add #{?@is_saving,󰒓 ,} to status-left or status-right
```

Reload your Tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

---

## 3. Configure Neovim

### Requirements

* Neovim
* `echasnovski/mini.sessions`

Install the Panekeeper Lua module:

```bash
cp ~/.config/panekeeper/neovim/panekeeper.lua \
   ~/.config/nvim/lua/panekeeper.lua
```

Then add the following to your `init.lua`:

```lua
require("panekeeper").setup()
```

---

# Usage

Panekeeper includes an FZF-powered workspace manager accessible directly from Tmux.

Open the launcher:

```text
Prefix + P
```

A floating project manager will appear.

---

## Load Project

Displays all saved workspaces.

Selecting a project will:

* Attach to an existing background session if running
* Otherwise rebuild the workspace from disk
* Restore associated Neovim sessions automatically

---

## New Project

Creates a new isolated workspace.

You will be prompted for:

* Project name

Panekeeper then:

1. Creates a new Tmux session.
2. Attaches you to it immediately.
3. Begins automatic background snapshots.

---

## Delete Project

Removes a project permanently.

Deleted items include:

* Saved Tmux layouts
* Neovim session data
* Workspace metadata

Use with caution.

---

# Manual Saving

Although the auto-save daemon continuously protects your workspace, you can create an immediate snapshot at any time:

```text
Prefix + W
```

---

# Directory Structure

```text
panekeeper/
├── bin/
│   ├── auto-save.sh
│   ├── manage-project.sh
│   └── helpers/
├── neovim/
│   └── panekeeper.lua
├── gui_examples/
├── fzf-launcher.sh
└── README.md
```

---

# GUI Launchers

Example launcher configurations are included for:

* Rofi
* Walker
* Fuzzel

See the `gui_examples/` directory for setup instructions.

---

# Dependencies

### Required

* Tmux
* Neovim
* fzf
* bash

### Neovim Plugins

* `echasnovski/mini.sessions`

---

# Why Panekeeper?

Most workspace tools restore terminal layouts or editor sessions independently.

Panekeeper treats your entire development environment as a single unit:

* Tmux panes know which Neovim session belongs to them.
* Neovim sessions know which project they belong to.
* Automatic snapshots keep everything synchronized.

The result is a workflow where you can stop working, reboot, and resume exactly where you left off.

---

# License

MIT License
