#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

bash_flags=()
if [[ $- == *e* ]]; then
  bash_flags=(-e)
fi

shopt -s nullglob
scripts=("$script_dir/ai"/setup-*.sh)
shopt -u nullglob

[[ ${#scripts[@]} -eq 0 ]] && exit 0

pids=() names=() logs=()
start=$SECONDS

for script in "${scripts[@]}"; do
  name=$(basename "$script" .sh)
  log=$(mktemp "${TMPDIR:-/tmp}/clouddots-${name}-XXXXXX.log")
  names+=("$name")
  logs+=("$log")
  bash "${bash_flags[@]}" "$script" >"$log" 2>&1 &
  pids+=($!)
done

failed=0
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

echo "[profile] ai: $((SECONDS - start))s"
if [[ $failed -ne 0 ]]; then
  exit 1
fi
