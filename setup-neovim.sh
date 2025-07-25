#!/usr/bin/env bash

# Clone or update neovim configuration
if [ -d "$HOME/.config/nvim" ] && [ "$(ls -A "$HOME/.config/nvim")" ]; then
  pushd "$HOME/.config/nvim" && git pull
  popd
else
  git clone https://github.com/scaryrawr/lazyvim ~/.config/nvim
fi
