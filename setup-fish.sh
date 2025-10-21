#!/usr/bin/env bash

mkdir -p "$HOME/.config/fish/conf.d"
mkdir -p "$HOME/.config/fish/functions"

# Ensure $HOME/.local/bin is on the PATH in fish
if [[ -d "$HOME/.local/bin" ]]; then
  fish --command='fish_add_path $HOME/.local/bin'
fi

# Ensure $HOME/.npm-global/bin is on the PATH in fish
if [[ -d "$HOME/.npm-global/bin" ]]; then
  fish --command='fish_add_path $HOME/.npm-global/bin'
fi

# Ensure $HOME/.cargo/bin is on the PATH in fish
if [[ -d "$HOME/.cargo/bin" ]]; then
  fish --command='fish_add_path $HOME/.cargo/bin'
fi

# Ensure $HOME/go/bin is on the PATH in fish if it exists
if [[ -d "$HOME/go/bin" ]]; then
  fish --command='fish_add_path $HOME/go/bin'
fi

if [[ -d "$HOME/.local/share/fnm" ]]; then
  fish --command='fish_add_path $HOME/.local/share/fnm'
fi

# Initialize fnm for fish only if fnm is installed
cat >"$HOME/.config/fish/conf.d/fnm.fish" <<EOF
status is-interactive && command -q fnm && fnm env --use-on-cd --shell fish | source
EOF

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' >"$HOME/.config/fish/conf.d/cargo.fish"

echo 'set -gx SHELL (which fish)' >"$HOME/.config/fish/conf.d/shell.fish"

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher jorgebucaran/replay.fish scaryrawr/tide scaryrawr/artifacts-helper.fish jorgebucaran/autopair.fish scaryrawr/codespace-nvm.fish scaryrawr/nvim.fish </dev/null"
fish --command="tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Fade --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Many icons' --transient=Yes"
fish --command="command -q zoxide && fisher install scaryrawr/zoxide.fish </dev/null"
fish --command="command -q fzf && fisher install scaryrawr/fzf.fish scaryrawr/monorepo.fish </dev/null"
fish --command="command -q eza && fisher install scaryrawr/fish-eza </dev/null"
fish --command="command -q tmux && fisher install scaryrawr/tmux.fish </dev/null && set -Ux TMUX_POWERLINE_BUBBLE_SEPARATORS true && set -Ux TMUX_SSHAUTO_START true"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"

sudo chsh -s $(which fish) $(whoami)
