#!/usr/bin/env bash

# Enable strict mode in CI or when explicitly requested
if [ "$STRICT_MODE" = "true" ] || [ "$CI" = "true" ]; then
  set -e
  BASH_FLAGS="-e"
else
  BASH_FLAGS=""
fi

script_dir=$(dirname "$(readlink -f "$0")")
original_node_path="$(command -v node 2>/dev/null || true)"
original_npm_path="$(command -v npm 2>/dev/null || true)"

prepend_path_entry() {
  local path_entry="$1"
  local existing_path
  local new_path="$path_entry"
  local path_parts=()

  IFS=: read -r -a path_parts <<< "$PATH"
  for existing_path in "${path_parts[@]}"; do
    [[ -z "$existing_path" || "$existing_path" == "$path_entry" ]] && continue
    new_path="$new_path:$existing_path"
  done

  export PATH="$new_path"
}

restore_preserved_nvm_node_paths() {
  local executable_path
  local bin_dir
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  nvm_dir="${nvm_dir%/}"

  for executable_path in "$original_node_path" "$original_npm_path"; do
    [[ -n "$executable_path" ]] || continue
    bin_dir="$(dirname "$executable_path")"
    if [[ "$bin_dir" == "$nvm_dir"/versions/node/*/bin || "$bin_dir" == */nvm/versions/node/*/bin ]]; then
      prepend_path_entry "$bin_dir"
    fi
  done
}

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

restore_preserved_nvm_node_paths

# Check for node and npm before installing fnm
if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
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

# Ensure fnm-managed node is on PATH for subsequent scripts
if command -v fnm &>/dev/null; then
  eval "$(fnm env --shell bash)"
fi

restore_preserved_nvm_node_paths

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
