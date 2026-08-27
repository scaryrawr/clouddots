#!/usr/bin/env bash
set -e

# Check if node is installed at /usr/bin/node (system-wide) and configure user-local global prefix
if node_path="$(command -v node 2>/dev/null)" && [[ "$node_path" == "/usr/bin/node" ]]; then
  echo "node is installed system-wide at /usr/bin/node, configuring user-local global directory"
  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global"
fi

export PATH="$(npm prefix -g)/bin:$PATH"

# Install language servers and tools via npm.
# Node-based tools live here (not Homebrew) so brew never installs its own
# `node`, which would conflict with the global node install in Codespaces.
npm_tools=(
  "tsc:typescript"
  "typescript-language-server:typescript-language-server"
  "vscode-json-language-server:vscode-langservers-extracted"
  "pyright:pyright"
  "prettier:prettier"
  "yaml-language-server:yaml-language-server"
  "markdownlint-cli2:markdownlint-cli2"
)

missing_packages=()
for tool in "${npm_tools[@]}"; do
  command_name="${tool%%:*}"
  package_name="${tool#*:}"
  if ! command -v "$command_name" &>/dev/null; then
    missing_packages+=("$package_name")
  fi
done

if [[ ${#missing_packages[@]} -gt 0 ]]; then
  npm install -g "${missing_packages[@]}"
fi

for tool in "${npm_tools[@]}"; do
  command_name="${tool%%:*}"
  if ! command -v "$command_name" &>/dev/null; then
    echo "Unable to install $command_name" >&2
    exit 1
  fi
done
