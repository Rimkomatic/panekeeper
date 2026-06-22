# GUI Application Launchers

This directory contains example scripts for integrating **Panekeeper** with popular application launchers and dynamic menus across both Wayland and X11 environments.

Using these launchers, you can create, load, switch, or delete Panekeeper workspaces directly from your desktop environment without opening the terminal UI.

---

## Overview

The launcher scripts provide a desktop-native workflow for workspace management.

Instead of opening Panekeeper through Tmux, you can:

* Create new projects
* Load existing projects
* Switch between workspaces
* Delete saved environments
* Launch isolated development sessions from global keybindings

These scripts are designed to work with common launchers and compositors while remaining easy to customize.

---

## Supported Launchers

Example integrations are provided for:

| Launcher | Environment                    | Script              |
| -------- | ------------------------------ | ------------------- |
| Walker   | Wayland                        | `walker_example.sh` |
| Fuzzel   | Wayland                        | `fuzzel_example.sh` |
| Wofi     | Wayland                        | `wofi_example.sh`   |
| Rofi     | X11 / Wayland (`rofi-wayland`) | `rofi_example.sh`   |
| dmenu    | X11                            | `dmenu_example.sh`  |

---

# Configuration

Each example script contains a dedicated configuration section near the top:

```bash
# ==============================================================================
# USER CONFIGURATION
# ==============================================================================
MANAGER_SCRIPT="$HOME/.config/panekeeper/bin/manage-project.sh"
LAUNCHER_CMD="walker --dmenu"
TERMINAL_CMD="wezterm start --always-new-process --"
# ==============================================================================
```

To use a launcher:

1. Copy the desired script to an executable location.
2. Adjust the configuration variables.
3. Bind the script to a global keyboard shortcut.

Example:

```bash
cp walker_example.sh ~/.local/bin/panekeeper-launcher
chmod +x ~/.local/bin/panekeeper-launcher
```

---

## Terminal Selection

Because launcher applications execute outside of an active terminal session, Panekeeper must spawn a terminal instance whenever a project is loaded or created.

Set the `TERMINAL_CMD` variable to your preferred terminal emulator.

### Supported Examples

#### WezTerm

```bash
TERMINAL_CMD="wezterm start --always-new-process --"
```

#### Alacritty

```bash
TERMINAL_CMD="alacritty -e"
```

#### Ghostty

```bash
TERMINAL_CMD="ghostty -e"
```

#### Kitty

```bash
TERMINAL_CMD="kitty --"
```

#### Foot

```bash
TERMINAL_CMD="foot -e"
```

> **Important:** Keep the trailing execution flags (`-e`, `--`, etc.) intact. These flags instruct the terminal to execute the Panekeeper command instead of launching a default interactive shell.

---

## Manager Script Path

The launchers expect Panekeeper to be installed at:

```text
~/.config/panekeeper/bin/manage-project.sh
```

This path is configured through:

```bash
MANAGER_SCRIPT="$HOME/.config/panekeeper/bin/manage-project.sh"
```

Desktop environments execute scripts independently of your repository location, so an absolute path is required.

If Panekeeper is installed elsewhere, update this variable accordingly.

---

# Window Manager Integration

The launchers are intended to be bound to global keyboard shortcuts within your compositor or window manager.

## Niri

Add the following to your `config.kdl`:

```kdl
binds {
    Mod+P { spawn "~/.local/bin/walker_example.sh"; }
}
```

---

## Hyprland

Add the following to your `hyprland.conf`:

```ini
bind = $mainMod, P, exec, ~/.local/bin/fuzzel_example.sh
```

---

## Sway

Add the following to your configuration file:

```bash
bindsym $mod+p exec ~/.local/bin/rofi_example.sh
```

---

## i3

Add the following to your configuration file:

```bash
bindsym $mod+p exec ~/.local/bin/rofi_example.sh
```

---

# Permissions

Before running any launcher script, ensure it is executable:

```bash
chmod +x ~/.local/bin/your_chosen_launcher.sh
```

---

# Recommended Workflow

1. Install Panekeeper.
2. Copy your preferred launcher script into `~/.local/bin`.
3. Configure `MANAGER_SCRIPT`.
4. Configure `TERMINAL_CMD`.
5. Add a compositor or window manager keybinding.
6. Reload your desktop configuration.
7. Launch Panekeeper with a single keyboard shortcut.

This provides a desktop-native workflow for managing isolated development environments without interacting directly with the terminal interface.
