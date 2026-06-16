#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config"

mkdir -p "$HOME/.tmux/plugins"
plugins=(
  "https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  "https://github.com/sainnhe/tmux-fzf $HOME/.tmux/plugins/tmux-fzf"
  "https://github.com/erikw/tmux-powerline $HOME/.tmux/plugins/tmux-powerline"
)

# Clone or pull each plugin
for plugin in "${plugins[@]}"; do
  repo_url=$(echo "$plugin" | awk '{print $1}')
  clone_dir=$(echo "$plugin" | awk '{print $2}')
  if [ -d "$clone_dir" ] && [ "$(ls -A $clone_dir)" ]; then
    (cd "$clone_dir" && git pull)
  else
    git clone "$repo_url" "$clone_dir"
  fi
done

"$HOME/.tmux/plugins/tmux-powerline/generate_config.sh"
if [[ ! -f "$HOME/.config/tmux-powerline/config.sh" && -f "$HOME/.config/tmux-powerline/config.sh.default" ]]; then
  mv "$HOME/.config/tmux-powerline/config.sh.default" "$HOME/.config/tmux-powerline/config.sh"
fi
if [[ -f "$HOME/.config/tmux-powerline/config.sh" ]]; then
  sed -i 's/export TMUX_POWERLINE_THEME="default"/export TMUX_POWERLINE_THEME="base16"/' "$HOME/.config/tmux-powerline/config.sh"
fi

cp -f "$config_dir/tmux/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/tmux-powerline/themes" "$HOME/.config/tmux-powerline/segments"
cp -f "$config_dir/tmux-powerline/segments/codespace_name.sh" "$HOME/.config/tmux-powerline/segments/codespace_name.sh"
cp -f "$config_dir/tmux-powerline/themes/base16.sh" "$HOME/.config/tmux-powerline/themes/base16.sh"
