#!/usr/bin/env bash
set -ex

# Just prepend to bashrc if it's not in it.
prepend_entries=(
  'export PATH="$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
  'export SHELL=$(which bash)'
)

for entry in "${prepend_entries[@]}"; do
  if ! grep -q "$entry" "$HOME/.bashrc"; then
    echo "$entry
$(cat $HOME/.bashrc)" >"$HOME/.bashrc"
  fi
done

# Just append to bashrc if it's not in it.
append_entries=(
  'command -v fnm && eval "$(fnm env --use-on-cd --shell bash)"'
)

for entry in "${append_entries[@]}"; do
  if ! grep -q "$entry" "$HOME/.bashrc"; then
    echo "$entry" >>"$HOME/.bashrc"
  fi
done
