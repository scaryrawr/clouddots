#!/usr/bin/env bash
set -e

# Check if node is installed at /usr/bin/node (system-wide) and configure user-local global prefix
if node_path="$(command -v node 2>/dev/null)" && [[ "$node_path" == "/usr/bin/node" ]]; then
  echo "node is installed system-wide at /usr/bin/node, configuring user-local global directory"
  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global"
  echo "Note: Make sure $HOME/.npm-global/bin is in your PATH"
fi

# Install language servers and tools via npm
npm install -g typescript typescript-language-server vscode-langservers-extracted pyright @typescript/native-preview
