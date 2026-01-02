#!/usr/bin/env bash

# Enable strict mode in CI or when explicitly requested
if [ "$STRICT_MODE" = "true" ] || [ "$CI" = "true" ]; then
  set -e
  BASH_FLAGS="-e"
else
  BASH_FLAGS=""
fi

script_dir=$(dirname "$(readlink -f "$0")")

bash $BASH_FLAGS "$script_dir/setup/core/system-deps.sh"

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
  fnm install 24
  fnm default 24
fi

# Install global npm tools
bash $BASH_FLAGS "$script_dir/setup/core/npm-tools.sh"

bash $BASH_FLAGS "$script_dir/setup/shells/setup-bash.sh"
bash $BASH_FLAGS "$script_dir/setup/shells/setup-zsh.sh"
bash $BASH_FLAGS "$script_dir/setup/shells/setup-fish.sh"

bash $BASH_FLAGS "$script_dir/setup/setup-editors.sh"
bash $BASH_FLAGS "$script_dir/setup/setup-terminal.sh"
bash $BASH_FLAGS "$script_dir/setup/setup-ai.sh"
