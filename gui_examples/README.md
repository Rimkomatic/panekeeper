### Configuring Your Terminal Emulator

By default, the GUI launchers are configured to spawn project sessions using **WezTerm**. 

If you use a different terminal, open the launcher script (e.g., `walker_example.sh`) and update the `TERMINAL_CMD` variable at the top of the file to match your emulator. 

Here are the correct execution commands for the most popular terminal emulators:

* **WezTerm:** `TERMINAL_CMD="wezterm start --always-new-process --"`
* **Alacritty:** `TERMINAL_CMD="alacritty -e"`
* **Ghostty:** `TERMINAL_CMD="ghostty -e"`
* **Kitty:** `TERMINAL_CMD="kitty --"`
* **Foot:** `TERMINAL_CMD="foot -e"`

*Note: The trailing flag (`-e` or `--`) is critical, as it tells the terminal to execute the Panekeeper script instead of opening a standard shell.*
