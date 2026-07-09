#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/fish/conf.d"

mkdir -p "$HOME/.config/fish/conf.d"
mkdir -p "$HOME/.config/fish/functions"

path_entries=(
  "$HOME/.local/bin"
  "/home/linuxbrew/.linuxbrew/bin"
  "/home/linuxbrew/.linuxbrew/sbin"
  "$HOME/.npm-global/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.local/share/fnm"
  "$HOME/.bun/bin"
)

for path_entry in "${path_entries[@]}"; do
  [[ -d "$path_entry" ]] && fish --command="contains -- \"$path_entry\" \$fish_user_paths; or fish_add_path \"$path_entry\""
done

# Ensure ~/.local/bin is first so shims override Homebrew/system binaries
[[ -d "$HOME/.local/bin" ]] && fish --command="fish_add_path --move \"$HOME/.local/bin\""

cp -f "$config_dir"/*.fish "$HOME/.config/fish/conf.d/"

fish --command='set -Ux COPILOT_HOOK_ALLOW_LOCALHOST 1'

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher jorgebucaran/replay.fish scaryrawr/copilot.fish scaryrawr/tide scaryrawr/codespace-nvm.fish scaryrawr/nvim.fish franciscolourenco/done </dev/null"
fish --command="if fisher list | string match -qx 'scaryrawr/artifacts-helper.fish'; fisher remove scaryrawr/artifacts-helper.fish </dev/null; end"
fish --command="tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Fade --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Many icons' --transient=Yes"
fish --command="command -q zoxide && fisher install scaryrawr/zoxide.fish </dev/null"
fish --command="command -q fzf && fisher install scaryrawr/fzf.fish scaryrawr/monorepo.fish </dev/null && set -Ux fzf_fd_opts --hidden --exclude .git --exclude .hg --exclude .svn && command -q delta && set -Ux fzf_diff_highlighter delta --paging=never"
fish --command="command -q eza && fisher install scaryrawr/fish-eza </dev/null"
fish --command="command -q tmux && fisher install scaryrawr/tmux.fish </dev/null && set -Ux TMUX_POWERLINE_BUBBLE_SEPARATORS true && set -Ux TMUX_SSHAUTO_START true"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
