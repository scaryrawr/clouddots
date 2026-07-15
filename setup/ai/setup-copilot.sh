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
)

for plugin in "${marketplace_plugins[@]}"; do
  copilot plugin marketplace add "$plugin" || true
done

for plugin in "${install_plugins[@]}"; do
  copilot plugin install "$plugin" || true
done

extensions=(
  "scaryrawr/copilot-cheap"
)

for extension in "${extensions[@]}"; do
  extension_dir="$HOME/.copilot/extensions/$(basename "$extension")"
  if [[ -d "$extension_dir/.git" ]]; then
    git -C "$extension_dir" fetch --prune origin
    remote_default_branch="$(git -C "$extension_dir" symbolic-ref --short refs/remotes/origin/HEAD)"
    git -C "$extension_dir" reset --hard "$remote_default_branch"
  else
    gh repo clone "$extension" "$extension_dir"
  fi
done
