#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.local/bin"

script_dir=$(dirname "$(readlink -f "$0")")

# Remove retired repo-managed compatibility and authentication shims.
deprecated_shims=(az bun bunx chafa npm npx pnpm pnpx yarn)
for shim_basename in "${deprecated_shims[@]}"; do
  local_shim="$HOME/.local/bin/$shim_basename"
  repo_shim="$script_dir/shims/$shim_basename"
  if [[ -L "$local_shim" && "$(readlink "$local_shim")" == "$repo_shim" ]]; then
    rm -f "$local_shim"
  fi
done

for shim in "$script_dir"/shims/*; do
  shim_basename="$(basename "$shim")"
  # Skip helper files (prefixed with _)
  [[ "$shim_basename" == _* ]] && continue

  local_shim="$HOME/.local/bin/$shim_basename"
  if [[ -f "$shim" && -x "$shim" ]]; then
    ln -sf "$shim" "$local_shim"
  fi
done
