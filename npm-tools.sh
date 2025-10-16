#!/usr/bin/env bash

# Check if node is installed at /usr/bin/node (system-wide) and configure user-local global prefix
NODE_PATH=$(which node)
if [[ "$NODE_PATH" == "/usr/bin/node" ]]; then
  echo "node is installed system-wide at /usr/bin/node, configuring user-local global directory"
  mkdir -p ~/.npm-global
  npm config set prefix ~/.npm-global
  echo "Note: Make sure ~/.npm-global/bin is in your PATH"
fi

# Install language servers and tools via npm
npm install -g typescript typescript-language-server vscode-langservers-extracted pyright @github/copilot @typescript/native-preview
npm upgrade -g
