#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")
for shim in "$script_dir"/shims/*; do
  if [ -f "$shim" ] && [ -x "$shim" ]; then
    ln -sf "$shim" "$HOME/.local/bin/$(basename "$shim")"
  fi
done