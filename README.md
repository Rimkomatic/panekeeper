# Panekeeper

> A robust, background-driven workspace orchestrator that bridges the gap between Tmux and Neovim.

If you use Tmux and Neovim, you've probably encountered the same problem: Tmux can restore windows and pane layouts, but Neovim reopens with none of your buffers, cursor positions, or editing context.

**Panekeeper** solves this by keeping your Tmux layout and Neovim state synchronized. Save, restore, and manage entire development environments without losing your workspace.

---

## Features

* Restore complete Tmux workspaces
* Restore Neovim buffers, folds, and cursor positions
* Git branch-aware Neovim sessions (automatically isolates state per branch)
* Automatic background snapshots
* Pane-aware Neovim session management
* Project-based workspace organization
* Fast FZF-powered project launcher
* Crash and reboot recovery
* Lightweight, decoupled architecture

---

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
git clone https://github.com/Rimkomatic/panekeeper.git 

```
It is recomemded to extract the files in ~/.config/panekeeper

### Directory Structure

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



## Requirements

* Tmux
* Neovim
* fzf
* bash

Needed Neovim plugins

* `echasnovski/mini.sessions`

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
set -g @resurrect-dir '~/.project-sessions/'

# Save the current project manually
bind-key W run-shell -b "~/.config/panekeeper/bin/manage-project.sh save '#S'"

# Start the auto-save daemon
run-shell -b "~/.config/panekeeper/bin/auto-save.sh"

```

### status bar indicator

```

 #S #{?@is_saving,󰒓 ,}\

```

Example config

```
# ==========================================
# Panekeeper Integration
# ==========================================

# 1. Start the background auto-save daemon (e.g., every 10 minutes)
run-shell -b "~/.config/panekeeper/bin/auto-save.sh 10"

# 2. Manual Save Shortcut (Prefix + W)
# Passes '#S' so the background daemon knows exactly which session to save
bind-key W run-shell -b "~/.config/panekeeper/bin/manage-project.sh save '#S'"

# 3. Launch the FZF Project Manager (Prefix + P)
# Opens the launcher in a clean, floating Tmux popup
bind-key P display-popup -E "~/.config/panekeeper/fzf-launcher.sh"

# ==========================================
# Optional Settings
# ==========================================

# Change the default save location (Panekeeper defaults to ~/.project-sessions)
# set -g @resurrect-dir '~/.custom-save-folder/'

# Add a visual indicator to your status bar when an auto-save occurs.
# Drop this variable into your existing status-left or status-right string:
# #{?@is_saving,󰒓 ,}

```


---

## 3. Configure Neovim

Install the Panekeeper Lua module:

```bash
cp ~/.config/panekeeper/neovim/panekeeper.lua \
   ~/.config/nvim/lua/panekeeper.lua
```

Then add the following to your `init.lua`:

```lua
require("panekeeper").setup()

```

Your mini session config should look like this 

```
return {
    {
        "echasnovski/mini.nvim",
        version = false,

        -- Ensure the plugin loads when Panekeeper sends the restore command
        cmd = { "TmuxSessionLoad" },

        config = function()
            -- 1. Initialize mini.sessions
            -- We disable auto-read/write because Panekeeper manages the state
            require("mini.sessions").setup({
                autoread = false,
                autowrite = false,
                directory = vim.fn.stdpath("state") .. "/sessions",
                file = "",
            })

            -- 2. Initialize the Panekeeper bridge
            require("panekeeper").setup()
        end,
    },
}

```



## 4. Configure according to preference 

We can set different time for the autosave function to run , by default it is 6.9 minutes (noice) and we can pass arguments in our `tmux.conf` file in order to get different run time.

```
# To run each 3 minutes 

run-shell -b "~/.config/panekeeper/bin/auto-save.sh 3"

```

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

# GUI Launchers

Example launcher configurations are included for:

* Rofi
* Walker
* Fuzzel

See the `gui_examples/` directory for setup instructions.

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
