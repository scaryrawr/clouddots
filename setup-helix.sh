#!/usr/bin/env bash

# Clone or update helix configuration
if [ -d "$HOME/.config/helix" ] && [ "$(ls -A "$HOME/.config/helix")" ]; then
  pushd "$HOME/.config/helix" && git pull
  popd
else
  git clone https://github.com/scaryrawr/dothelix ~/.config/helix
fi
