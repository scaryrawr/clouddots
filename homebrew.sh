#!/usr/bin/env bash

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install fzf eza zoxide ripgrep chafa bat fd git-delta tmux sst/tap/opencode