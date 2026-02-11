#!/usr/bin/env bash
# Common helper sourced by all shims. Callers set AUTH_ENV_VAR before sourcing.
# The command name and real binary are auto-detected from the shim's filename.

set -e

cmd_name="$(basename "${BASH_SOURCE[1]}")"

# Find the real binary, skipping this shim to avoid recursive calls
real_bin=""
for p in $(type -aP "$cmd_name"); do
  if [ "$p" != "${BASH_SOURCE[1]}" ] && [ "$p" != "$(readlink -f "${BASH_SOURCE[1]}")" ]; then
    real_bin="$p"
    break
  fi
done

if [ -z "$real_bin" ]; then
  echo "Error: could not find real $cmd_name CLI" >&2
  exit 1
fi

# Rebuild PATH without the shim directory to prevent recursive calls
shim_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
IFS=':' read -r -a path_parts <<< "$PATH"
new_path=()
for p in "${path_parts[@]}"; do
  [[ -n "$p" && "$p" != "$shim_dir" ]] && new_path+=("$p")
done
PATH=$(IFS=':'; printf '%s' "${new_path[*]}")
export PATH

# If no auth env var specified, just exec the real binary
if [ -z "${AUTH_ENV_VAR:-}" ]; then
  exec "$real_bin" "$@"
fi

# Check if we have auth helper, if not, just call the command directly
auth_helper="$HOME/ado-auth-helper"
if command -v "$auth_helper" &> /dev/null; then
  export "$AUTH_ENV_VAR=$($auth_helper get-access-token)"
  exec "$real_bin" "$@"
else
  exec "$real_bin" "$@"
fi
