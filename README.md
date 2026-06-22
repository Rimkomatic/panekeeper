# Panekeeper

> Save and restore your entire Tmux + Neovim workspace with a single command.

If you use Tmux and Neovim together, you've probably encountered the same problem:

* Tmux restores windows and pane layouts.
* Neovim starts with no buffers open.
* Cursor positions are lost.
* Editing context disappears.

After a reboot, crash, or accidental terminal closure, rebuilding your workspace becomes a manual process.

**Panekeeper** bridges the gap between Tmux and Neovim by treating your entire development environment as a single workspace.

When a project is restored, Panekeeper:

* Restores the Tmux session layout.
* Locates every pane running Neovim.
* Restores the correct Neovim session for each pane.
* Restores buffers, folds, cursor positions, and editing context.
* Automatically isolates Neovim state per Git branch.

The result is a workflow where you can stop working, reboot your machine, and continue exactly where you left off.

---

## Demo


---

## Features

* Full Tmux workspace restoration
* Pane-aware Neovim session management
* Git branch-aware Neovim sessions
* Automatic workspace snapshots
* Crash and reboot recovery
* Project-based workspace organization
* FZF-powered project launcher
* Lightweight shell-based architecture
* Decoupled design built on existing tools
* No database required

---

## How It Works

```text
Project
    │
    ▼
Panekeeper
    │
    ├── tmux-resurrect
    │       restores layouts
    │
    └── mini.sessions
            restores Neovim state
```

Panekeeper acts as the bridge between Tmux and Neovim, ensuring both are restored together.

---

## Restore Flow

```text
Load Project
    │
    ▼
Restore Tmux Layout
    │
    ▼
Locate Neovim Panes
    │
    ▼
Inject Restore Commands
    │
    ▼
Restore Pane-Specific Sessions
```

Every Neovim instance restores its own session based on:

```text
tmux_session_window_pane
```

and, when applicable:

```text
tmux_session_window_pane__git_branch
```

This allows different Git branches to maintain independent editor state.

---

# Installation

## 1. Clone the Repository

```bash
git clone https://github.com/Rimkomatic/panekeeper.git
```

It is recommended to place Panekeeper inside:

```text
~/.config/panekeeper
```

Example:

```bash
git clone https://github.com/Rimkomatic/panekeeper.git \
    ~/.config/panekeeper
```

---

## Directory Structure

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

## Requirements

### Core

* Tmux
* Neovim
* Bash
* fzf

### Neovim Plugins

```lua
echasnovski/mini.sessions
```

---

## Make Scripts Executable

```bash
chmod +x ~/.config/panekeeper/bin/*.sh
chmod +x ~/.config/panekeeper/bin/helpers/scripts/*.sh
chmod +x ~/.config/panekeeper/fzf-launcher.sh
```

---

# Tmux Configuration

Add the following to your `~/.tmux.conf`:

```tmux
set -g @resurrect-dir '~/.project-sessions/'

bind-key W run-shell -b "~/.config/panekeeper/bin/manage-project.sh save '#S'"

run-shell -b "~/.config/panekeeper/bin/auto-save.sh"
```

---

## Status Bar Indicator

Add this to your status line:

```tmux
#{?@is_saving,󰒓 ,}
```

Example:

```tmux
set -g status-left "#S #{?@is_saving,󰒓 ,}"
```

---

## Full Example

```tmux
# ==========================================
# Panekeeper Integration
# ==========================================

# Auto-save every 10 minutes
run-shell -b "~/.config/panekeeper/bin/auto-save.sh 10"

# Manual Save
bind-key W run-shell -b "~/.config/panekeeper/bin/manage-project.sh save '#S'"

# Project Launcher
bind-key P display-popup -E "~/.config/panekeeper/fzf-launcher.sh"

# ==========================================
# Optional Settings
# ==========================================

# Custom save directory
# set -g @resurrect-dir '~/.custom-save-folder/'

# Status bar indicator
# #{?@is_saving,󰒓 ,}
```

---

# Neovim Configuration

Copy the Lua bridge:

```bash
cp ~/.config/panekeeper/neovim/panekeeper.lua \
   ~/.config/nvim/lua/panekeeper.lua
```

Add to your `init.lua`:

```lua
require("panekeeper").setup()
```

---

## mini.sessions Configuration

```lua
return {
    {
        "echasnovski/mini.nvim",
        version = false,

        cmd = { "TmuxSessionLoad" },

        config = function()
            require("mini.sessions").setup({
                autoread = false,
                autowrite = false,
                directory = vim.fn.stdpath("state") .. "/sessions",
                file = "",
            })

            require("panekeeper").setup()
        end,
    },
}
```

---

# Auto-Save Configuration

By default:

```text
1 minute
```

Custom interval:

```tmux
run-shell -b "~/.config/panekeeper/bin/auto-save.sh 5"
```

This runs a snapshot every:

```text
5 minutes
```

---

# Project Management

## Load Project

Displays all saved workspaces.

Selecting a project will:

* Attach to an existing session if already running.
* Restore from disk if not running.
* Restore all associated Neovim sessions.

---

## Create Project

Creates a new isolated workspace.

You will be prompted for:

```text
Project Name
```

Panekeeper then:

1. Creates a new Tmux session.
2. Attaches you immediately.
3. Starts automatic snapshotting.

---

## Delete Project

Removes a project permanently.

Deleted items include:

* Saved Tmux layouts
* Neovim session files
* Workspace metadata

Use with caution.

---

# Manual Save

Although the auto-save daemon continuously protects your workspace, you can create an immediate snapshot at any time:

```text
Prefix + W
```

---

# GUI Launchers

Example launchers are included for:

* Rofi
* Walker
* Fuzzel

See the `gui_examples/` directory for setup instructions.

---

# Why Panekeeper?

Most workspace tools restore either:

* Terminal layouts
* Editor sessions

Panekeeper restores both.

```text
Tmux panes
        │
        ▼
Neovim sessions
        │
        ▼
Complete workspace recovery
```

By making Tmux and Neovim aware of each other, Panekeeper provides a workflow where:

* Reboots are painless.
* Crashes are recoverable.
* Context switching is instant.
* Development environments become portable.

---

# Acknowledgements

Panekeeper builds upon the excellent work of:

* tmux-resurrect
* mini.sessions
* fzf

---

# License

MIT License
