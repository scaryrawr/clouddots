#!/usr/bin/env bash
set -ex

# Install language servers and tools via npm (assumes node/npm are available via fnm)
npm install -g typescript typescript-language-server vscode-langservers-extracted pyright
