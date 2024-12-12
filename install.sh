#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

# Homebrew does not work on aarch64 linux
[[ "$(uname -m)" != "aarch64" ]] && $script_dir/homebrew.sh

$script_dir/apt.sh

$script_dir/configbash.sh
$script_dir/configzsh.sh
$script_dir/configfish.sh

if [ "$CODESPACES" = "true" ]; then
    $script_dir/configgit.sh
fi

cp $script_dir/p10k.zsh $HOME/.p10k.zsh
