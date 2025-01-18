#!/usr/bin/env bash

# Just prepend to bashrc if it's not in it.
prepend_entries=(
	'[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
)

for entry in "${prepend_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.bashrc"; then
		echo "$entry
$(cat $HOME/.bashrc)" > "$HOME/.bashrc"
	fi
done

# Just append to bashrc if it's not in it.
append_entries=()

for entry in "${append_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.bashrc"; then
		echo "$entry" >> "$HOME/.bashrc"
	fi
done
