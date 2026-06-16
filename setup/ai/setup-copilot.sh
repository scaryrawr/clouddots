#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/copilot"

mkdir -p "$HOME/.copilot"

config_file="$HOME/.copilot/config.json"
if [[ ! -f "$config_file" ]]; then
  cp -f "$config_dir/config.json" "$config_file"
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
  "chrome-devtools@scarypilot"
  "digivolution@scarypilot"
)

# Only add azure-devops plugin if the repo origin is an Azure DevOps URL
origin_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$origin_url" == *"dev.azure.com/"* ]] || [[ "$origin_url" == *".visualstudio.com/"* ]] || [[ "$origin_url" == *"ssh.dev.azure.com:"* ]]; then
  install_plugins+=("azure-devops@scarypilot")
fi

for plugin in "${marketplace_plugins[@]}"; do
  copilot plugin marketplace add "$plugin" || true
done

for plugin in "${install_plugins[@]}"; do
  copilot plugin install "$plugin" || true
done
