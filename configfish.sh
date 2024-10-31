#!/usr/bin/env bash

mkdir -p $HOME/.config/fish/conf.d
mkdir -p $HOME/.config/fish/functions

echo 'test -f /home/linuxbrew/.linuxbrew/bin/brew && /home/linuxbrew/.linuxbrew/bin/brew shellenv | source' > $HOME/.config/fish/conf.d/brew.fish

echo 'command -q fnm && fnm env --use-on-cd --shell fish | source' > $HOME/.config/fish/conf.d/fnm.fish

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' > $HOME/.config/fish/conf.d/cargo.fish

echo 'command -sq zoxide && zoxide init fish | source' > $HOME/.config/fish/conf.d/zoxide.fish

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher jorgebucaran/replay.fish scaryrawr/tide scaryrawr/artifacts-helper.fish jorgebucaran/autopair.fish </dev/null"
fish --command="tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Fade --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Many icons' --transient=Yes"
fish --command="command -q fzf && fisher install patrickf1/fzf.fish </dev/null"
fish --command="command -q eza && fisher install scaryrawr/fish-eza </dev/null"
test -f "$NVM_DIR/nvm.sh" && fish --command="fisher install scaryrawr/codespace-nvm.fish </dev/null"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
fish --command="fish_add_path ~/.deno/bin"