#!/usr/bin/env bash

# Clone or update helix configuration
if [ -d "$HOME/.config/helix" ] && [ "$(ls -A "$HOME/.config/helix")" ] && [ -d "$HOME/.config/helix/.git" ]; then
  (cd "$HOME/.config/helix" && git pull)
else
  git clone https://github.com/scaryrawr/dothelix ~/.config/helix
fi
