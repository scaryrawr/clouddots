#!/usr/bin/env bash
set -ex

script_dir=$(dirname "$(readlink -f "$0")")


bash "$script_dir/system-deps.sh"

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
bash "$script_dir/npm-tools.sh"

bash "$script_dir/setup-bash.sh"
bash bash "$script_dir/setup-zsh.sh"
bash "$script_dir/setup-fish.sh"
bash "$script_dir/setup-tmux.sh"
bash "$script_dir/setup-vscode.sh"

if [ "$CODESPACES" = "true" ]; then
    bash "$script_dir/setup-git.sh"
fi

cp "$script_dir/p10k.zsh" "$HOME/.p10k.zsh"
