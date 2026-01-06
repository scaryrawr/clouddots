#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

bash_flags=()
if [[ $- == *e* ]]; then
  bash_flags=(-e)
fi

shopt -s nullglob
scripts=("$script_dir/ai"/setup-*.sh)
shopt -u nullglob

for script in "${scripts[@]}"; do
  bash "${bash_flags[@]}" "$script"
done
