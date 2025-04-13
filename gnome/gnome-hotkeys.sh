#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Save with 'dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > gnome-keybindings.dconf'
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$SCRIPT_DIR/gnome-keybindings.dconf"