#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

$script_dir/apt.sh

# Homebrew does not work on aarch64 linux
 [[ "$(uname -m)" != "aarch64" ]] && $script_dir/homebrew.sh

$script_dir/configzsh.sh
$script_dir/configfish.sh
$script_dir/tide.fish
$script_dir/configgit.sh
cp $script_dir/p10k.zsh $HOME/.p10k.zsh
