#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

bash_flags=()
if [[ $- == *e* ]]; then
  bash_flags=(-e)
fi

shopt -s nullglob
scripts=("$script_dir/terminal"/setup-*.sh)
shopt -u nullglob

pids=() names=() logs=()
start=$SECONDS
failed=0

cleanup_parallel_scripts() {
  local pid log_path

  trap - EXIT INT TERM

  for pid in "${pids[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done

  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  for log_path in "${logs[@]}"; do
    [[ -n "$log_path" ]] && rm -f "$log_path"
  done
}

if [[ ${#scripts[@]} -eq 0 ]]; then
  echo "[profile] terminal: 0s"
  exit 0
fi

trap 'cleanup_parallel_scripts' EXIT
trap 'cleanup_parallel_scripts; exit 130' INT TERM

for script in "${scripts[@]}"; do
  name=$(basename "$script" .sh)
  log=$(mktemp "${TMPDIR:-/tmp}/clouddots-${name}-XXXXXX.log")
  names+=("$name")
  logs+=("$log")
  bash "${bash_flags[@]}" "$script" >"$log" 2>&1 &
  pids+=($!)
done

for i in "${!pids[@]}"; do
  if wait "${pids[$i]}"; then
    echo "[setup]   ✓ ${names[$i]}"
    grep -a '^\[profile\]' "${logs[$i]}" || true
  else
    failed=1
    echo "[setup]   ✗ ${names[$i]} FAILED:"
    cat "${logs[$i]}"
  fi
  rm -f "${logs[$i]}"
  logs[i]=""
done

trap - EXIT INT TERM
echo "[profile] terminal: $((SECONDS - start))s"
if [[ $failed -ne 0 ]]; then
  exit 1
fi
