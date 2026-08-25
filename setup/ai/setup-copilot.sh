#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/copilot"

mkdir -p "$HOME/.copilot"

config_file="$HOME/.copilot/settings.json"
dotfiles_settings="$config_dir/settings.json"
if [[ -f "$config_file" ]]; then
  # Merge dotfiles settings into the existing settings, letting dotfiles values win.
  tmp_settings="$(mktemp)"
  jq -s '.[0] * .[1] | del(.enabledPlugins["copilot@scarypilot"])' \
    "$config_file" "$dotfiles_settings" >"$tmp_settings"
  mv "$tmp_settings" "$config_file"
else
  cp -f "$dotfiles_settings" "$config_file"
fi

cp -f "$config_dir/copilot-instructions.md" "$HOME/.copilot/copilot-instructions.md"
cp -f "$config_dir/lsp-config.json" "$HOME/.copilot/lsp-config.json"

legacy_extension_dir="$HOME/.copilot/extensions/copilot-local-llm"
if [[ -d "$legacy_extension_dir" ]]; then
  rm -rf -- "$legacy_extension_dir"
fi
