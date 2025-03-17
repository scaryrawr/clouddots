#!/usr/bin/env bash

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Create or overwrite tmux configuration
cat > "$HOME/.tmux.conf" << EOF
set -g mouse on
set-option -sg escape-time 10
set-option -g focus-events on
set-option -sa terminal-features ',*:RGB'
EOF