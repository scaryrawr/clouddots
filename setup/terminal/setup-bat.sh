#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/bat"

mkdir -p "$HOME/.config/bat"
cp -f "$config_dir/config" "$HOME/.config/bat/config"
