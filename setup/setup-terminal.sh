#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

bash_flags=()
if [[ $- == *e* ]]; then
  bash_flags=(-e)
fi

scripts=(
  "$script_dir/terminal/setup-tmux.sh"
  "$script_dir/terminal/setup-git.sh"
)

for script in "${scripts[@]}"; do
  bash "${bash_flags[@]}" "$script"
done
