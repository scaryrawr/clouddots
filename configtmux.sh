#!/usr/bin/env bash

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Create or overwrite tmux configuration
cat > "$HOME/.tmux.conf" << EOF
set -g mouse on
set-option -sg escape-time 10
set-option -g focus-events on
set-option -sa terminal-features ',*:RGB'
set -g default-terminal "tmux-256color"

# status bar
set -g status-style bg=default

set -g status-left "#H - Session #S"

set -g status-justify centre
set -g window-status-format "#I: #W"
set -g window-status-current-style "underscore"

set-option -g status-right "%a %d %b %l:%M %p"
EOF
