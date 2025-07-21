#!/usr/bin/env bash
set -ex

# Check if npm is installed under /usr (system-wide) and configure user-local global prefix
NPM_PATH=$(which npm)
if [[ "$NPM_PATH" == /usr/* ]]; then
    echo "npm is installed system-wide under /usr, configuring user-local global directory"
    mkdir -p ~/.npm-global
    npm config set prefix ~/.npm-global
    echo "Note: Make sure ~/.npm-global/bin is in your PATH"
fi

# Install language servers and tools via npm
npm install -g typescript typescript-language-server vscode-langservers-extracted pyright
