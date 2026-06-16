#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/playwright"

# setup playwright skills globally
(
  cd "$HOME"
  playwright-cli install --skills agents
)

mkdir -p "$HOME/.playwright"
cp -f "$config_dir/cli.config.json" "$HOME/.playwright/cli.config.json"
