#!/usr/bin/env bash
set -e

# Homebrew refuses to update its download trust store when this directory is
# group-writable, which can be inherited from Codespaces' default umask.
mkdir -p "$HOME/.homebrew"
chmod go-w "$HOME/.homebrew"

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ensure brew is on PATH for the rest of this script
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Homebrew may use Ubuntu's system Git, which does not support the global
# `zdiff3` setting used by newer Git versions.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=merge.conflictstyle
export GIT_CONFIG_VALUE_0=diff3

brew install -y \
  ast-grep \
  fzf \
  eza \
  zoxide \
  ripgrep \
  chafa \
  bat \
  fd \
  git-delta \
  ffmpeg \
  imagemagick \
  herdr \
  scaryrawr/formulae/sl \
  modem-dev/tap/hunk \
  marksman \
  copilot-cli@prerelease \
  neovim \
  uv \
  worktrunk

# Language toolchains and LSP servers/formatters expected by our LazyVim config
# (https://github.com/scaryrawr/lazyvim). These are normally installed on demand
# by Mason, which fails on some Codespaces; pre-install them so the enabled
# language extras work out-of-the-box. Servers already provided elsewhere are
# omitted: marksman (above), pyright/typescript/tsgo/json/eslint LSPs (npm-tools.sh),
# python via uv, and node-based tools (prettier, yaml-language-server,
# markdownlint-cli2) which are installed via npm in npm-tools.sh so Homebrew
# never pulls in its own `node` (Codespaces ships a global node install).
brew install -y \
  go \
  gopls \
  gofumpt \
  delve \
  rust \
  rust-analyzer \
  zig \
  zls \
  llvm \
  cmake \
  cmake-language-server \
  ruff \
  taplo \
  oxlint
