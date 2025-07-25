#!/usr/bin/env bash

# Enable strict mode in CI or when explicitly requested
if [ "$STRICT_MODE" = "true" ] || [ "$CI" = "true" ]; then
    set -e
    BASH_FLAGS="-e"
else
    BASH_FLAGS=""
fi

script_dir=$(dirname "$(readlink -f "$0")")

bash $BASH_FLAGS "$script_dir/system-deps.sh"

# Check for node and npm before installing fnm
if ! command -v node &>/dev/null && ! command -v npm &>/dev/null; then
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
fi

# Install global npm tools
bash $BASH_FLAGS "$script_dir/npm-tools.sh"

bash $BASH_FLAGS "$script_dir/setup-bash.sh"
bash $BASH_FLAGS "$script_dir/setup-zsh.sh"
bash $BASH_FLAGS "$script_dir/setup-fish.sh"
bash $BASH_FLAGS "$script_dir/setup-neovim.sh"
bash $BASH_FLAGS "$script_dir/setup-tmux.sh"
bash $BASH_FLAGS "$script_dir/setup-vscode.sh"
bash $BASH_FLAGS "$script_dir/setup-opencode.sh"

if [ "$CODESPACES" = "true" ]; then
  bash $BASH_FLAGS "$script_dir/setup-git.sh"
fi

cp "$script_dir/p10k.zsh" "$HOME/.p10k.zsh"
