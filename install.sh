#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")


"$script_dir/apt.sh"

# Install fnm if not present
if ! command -v fnm &>/dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash
  export PATH="$HOME/.local/share/fnm:$PATH"
fi

# Ensure fnm is initialized for this script
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --shell bash)"

# Install latest LTS node and set as default
fnm install 22
fnm default 22

# Install global npm tools
"$script_dir/npm-global-tools.sh"

"$script_dir/configbash.sh"
"$script_dir/configzsh.sh"
"$script_dir/configfish.sh"
"$script_dir/configtmux.sh"
"$script_dir/configvscode.sh"

if [ "$CODESPACES" = "true" ]; then
    "$script_dir/configgit.sh"
fi

cp "$script_dir/p10k.zsh" "$HOME/.p10k.zsh"
