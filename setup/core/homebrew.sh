#!/usr/bin/env bash
set -e

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ensure brew is on PATH for the rest of this script
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew install \
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
  tmux \
  anomalyco/tap/opencode \
  scaryrawr/formulae/sl \
  scaryrawr/formulae/olaunch \
  modem-dev/tap/hunk \
  marksman \
  helix \
  copilot-cli@prerelease \
  codex \
  neovim \
  lazygit \
  uv \
  worktrunk
