#!/usr/bin/env bash

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
  fzf \
  eza \
  zoxide \
  ripgrep \
  chafa \
  bat \
  fd \
  git-delta \
  tmux \
  scaryrawr/formulae/sl \
  marksman \
  helix \
  copilot-cli@prerelease \
  neovim \
  lazygit \
  worktrunk
