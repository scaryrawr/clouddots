#!/usr/bin/env bash

# Enable strict mode in CI or when explicitly requested
if [ "$STRICT_MODE" = "true" ] || [ "$CI" = "true" ]; then
  set -e
  BASH_FLAGS="-e"
else
  BASH_FLAGS=""
fi

script_dir=$(dirname "$(readlink -f "$0")")

_setup_start=$SECONDS

# Run scripts in parallel, capturing each script's output to a temp file.
# Prints ✓/✗ per script as jobs complete; dumps captured output on failure.
# Returns 1 if any script failed.
# Usage: run_parallel "label" script1 script2 ...
run_parallel() {
  local label="$1"; shift
  local pids=() names=() logs=() name log
  local start=$SECONDS

  echo "[setup] Parallel group: $label"

  for script in "$@"; do
    name=$(basename "$script" .sh)
    log=$(mktemp "${TMPDIR:-/tmp}/clouddots-${name}-XXXXXX.log")
    names+=("$name")
    logs+=("$log")
    # SC2086: BASH_FLAGS is intentionally unquoted so "-e" is passed as a
    # separate flag argument to bash rather than as a single string argument.
    # shellcheck disable=SC2086
    bash $BASH_FLAGS "$script" >"$log" 2>&1 &
    pids+=($!)
  done

  local failed=0
  for i in "${!pids[@]}"; do
    if wait "${pids[$i]}"; then
      echo "[setup]   ✓ ${names[$i]}"
    else
      failed=1
      echo "[setup]   ✗ ${names[$i]} FAILED:"
      cat "${logs[$i]}"
    fi
    rm -f "${logs[$i]}"
  done

  echo "[profile] $label: $((SECONDS - start))s"
  if [[ $failed -ne 0 ]]; then
    echo "[setup] ERROR: one or more scripts in '$label' failed"
    return 1
  fi
}

# === Core (sequential) ===
echo "[setup] === Core ==="

_stage=$SECONDS
bash $BASH_FLAGS "$script_dir/setup/core/system-deps.sh"
echo "[profile] system-deps: $((SECONDS - _stage))s"

# Ensure bun is on PATH for subsequent scripts
export PATH="$HOME/.bun/bin:$PATH"

_stage=$SECONDS
bash $BASH_FLAGS "$script_dir/setup/core/homebrew.sh"
echo "[profile] homebrew: $((SECONDS - _stage))s"

# Ensure homebrew is on PATH for subsequent scripts
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

_stage=$SECONDS
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
echo "[profile] node/fnm: $((SECONDS - _stage))s"

_stage=$SECONDS
# Install global npm tools
bash $BASH_FLAGS "$script_dir/setup/core/npm-tools.sh"
echo "[profile] npm-tools: $((SECONDS - _stage))s"

# Ensure npm global bin is on PATH for subsequent scripts
export PATH="$HOME/.npm-global/bin:$PATH"

# === Parallel: shells + editors + terminal + ai ===
# All six groups are independent after core completes.
echo "[setup] === Parallel Setup ==="
run_parallel "shells-and-tools" \
  "$script_dir/setup/shells/setup-bash.sh" \
  "$script_dir/setup/shells/setup-zsh.sh" \
  "$script_dir/setup/shells/setup-fish.sh" \
  "$script_dir/setup/setup-editors.sh" \
  "$script_dir/setup/setup-terminal.sh" \
  "$script_dir/setup/setup-ai.sh"

# === Shims (after everything) ===
_stage=$SECONDS
bash $BASH_FLAGS "$script_dir/setup/setup-shims.sh"
echo "[profile] shims: $((SECONDS - _stage))s"

echo "[profile] total: $((SECONDS - _setup_start))s"
