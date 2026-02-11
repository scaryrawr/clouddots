#!/usr/bin/env bash

mkdir -p "$HOME/.local/bin"

script_dir=$(dirname "$(readlink -f "$0")")
for shim in "$script_dir"/shims/*; do
  shim_basename="$(basename "$shim")"
  # Skip helper files (prefixed with _)
  [[ "$shim_basename" == _* ]] && continue
  if [ -f "$shim" ] && [ -x "$shim" ]; then
    ln -sf "$shim" "$HOME/.local/bin/$shim_basename"
  fi
done