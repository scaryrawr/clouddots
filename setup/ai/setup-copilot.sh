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
  jq -s '.[0] * .[1]' "$config_file" "$dotfiles_settings" >"$tmp_settings"
  mv "$tmp_settings" "$config_file"
else
  cp -f "$dotfiles_settings" "$config_file"
fi

cp -f "$config_dir/copilot-instructions.md" "$HOME/.copilot/copilot-instructions.md"
cp -f "$config_dir/lsp-config.json" "$HOME/.copilot/lsp-config.json"

# Deploy user-level copilot-notify extension
notify_src="$script_dir/copilot-notify/extension.mjs"
notify_dest="$HOME/.copilot/extensions/copilot-notify"
mkdir -p "$notify_dest"
cp -f "$notify_src" "$notify_dest/extension.mjs"

marketplace_plugins=(
  "scaryrawr/scarypilot"
)

install_plugins=(
  "copilot@scarypilot"
  "digivolution@scarypilot"
)

for plugin in "${marketplace_plugins[@]}"; do
  copilot plugin marketplace add "$plugin" || true
done

for plugin in "${install_plugins[@]}"; do
  copilot plugin install "$plugin" || true
done
