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

# Ensure bun is on PATH for subsequent scripts
export PATH="$HOME/.bun/bin:$PATH"

bash $BASH_FLAGS "$script_dir/setup/core/homebrew.sh"

# Ensure homebrew is on PATH for subsequent scripts
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Prefer Node and nvm supplied by the host environment; use fnm only as fallback.
if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
  nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$nvm_dir/nvm.sh" ]]; then
    export NVM_DIR="$nvm_dir"
    # shellcheck disable=SC1091 # NVM is provided by the host environment.
    source "$NVM_DIR/nvm.sh"
    nvm install 24
    nvm alias default 24
  else
    if ! command -v fnm &>/dev/null; then
      curl -fsSL https://fnm.vercel.app/install | bash
    fi
    export PATH="$HOME/.local/share/fnm:$PATH"
    if ! command -v fnm &>/dev/null; then
      echo "Unable to install fnm" >&2
      exit 1
    fi
    eval "$(fnm env --shell bash)"
    fnm install 24
    fnm default 24
  fi
fi

# Install global npm tools
bash $BASH_FLAGS "$script_dir/setup/core/npm-tools.sh"

# Ensure npm global bin is on PATH for subsequent scripts
export PATH="$HOME/.npm-global/bin:$PATH"

bash $BASH_FLAGS "$script_dir/setup/shells/setup-bash.sh"
bash $BASH_FLAGS "$script_dir/setup/shells/setup-zsh.sh"
bash $BASH_FLAGS "$script_dir/setup/shells/setup-fish.sh"

bash $BASH_FLAGS "$script_dir/setup/setup-editors.sh"
bash $BASH_FLAGS "$script_dir/setup/setup-terminal.sh"
bash $BASH_FLAGS "$script_dir/setup/setup-ai.sh"
bash $BASH_FLAGS "$script_dir/setup/setup-shims.sh"

sudo chsh -s $(which fish) $USER
