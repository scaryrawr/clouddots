#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

ssh_config="$HOME/.ssh/config"
touch "$ssh_config"
chmod 600 "$ssh_config"

# Forward terminal passthrough capability env vars for all outbound SSH connections.
# This allows remote applications to know the outer terminal's capabilities
# (e.g. true color, terminal program identity) so they can use passthrough
# protocols (Kitty graphics, OSC sequences, etc.) through tmux allow-passthrough.
# Multiple Host * blocks are valid in SSH config — SendEnv accumulates across them.
passthrough_block="Host *
    SendEnv COLORTERM TERM_PROGRAM TERM_PROGRAM_VERSION"

# Use TERM_PROGRAM_VERSION as the idempotency sentinel — it's the most specific
# variable and unlikely to appear in a pre-existing SSH config.
if ! grep -qE '^[[:space:]]*SendEnv[[:space:]].*TERM_PROGRAM_VERSION' "$ssh_config"; then
  printf '\n%s\n' "$passthrough_block" >>"$ssh_config"
fi
