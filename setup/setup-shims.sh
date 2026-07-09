#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.local/bin"

script_dir=$(dirname "$(readlink -f "$0")")
codespace_shim_dir="/usr/local/share/codespace-shims"

for shim in "$script_dir"/shims/*; do
  shim_basename="$(basename "$shim")"
  # Skip helper files (prefixed with _)
  [[ "$shim_basename" == _* ]] && continue

  local_shim="$HOME/.local/bin/$shim_basename"
  if [[ -x "$codespace_shim_dir/$shim_basename" ]]; then
    # Avoid a resolver loop between our shim and the Codespaces feature shim.
    [[ -L "$local_shim" ]] && rm -f "$local_shim"
    continue
  fi

  if [ -f "$shim" ] && [ -x "$shim" ]; then
    ln -sf "$shim" "$local_shim"
  fi
done
