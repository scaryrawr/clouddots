#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/herdr"

mkdir -p "$HOME/.config/herdr"
cp -f "$config_dir/config.toml" "$HOME/.config/herdr/config.toml"
