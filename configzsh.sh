#!/usr/bin/env bash

# Just prepend to zshrc if it's not in it.
prepend_entries=(
	"zstyle ':omz:plugins:eza' 'icons' yes"
	'export PATH="$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
	'export SHELL=$(which zsh)'
	'ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
	'ZSH_TMUX_AUTOSTART=false'
	'ZSH_TMUX_AUTONAME_SESSION=true'
	'ZSH_TMUX_AUTOREFRESH=true'
	'export TMUX_POWERLINE_BUBBLE_SEPARATORS=true'
)

for entry in "${prepend_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.zshrc"; then
		echo "$entry
$(cat $HOME/.zshrc)" > "$HOME/.zshrc"
	fi
done

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
mkdir -p "$ZSH_CUSTOM"

# Array of plugins to clone
plugins=(
	"https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
	"https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions"
	"https://github.com/hlissner/zsh-autopair $ZSH_CUSTOM/plugins/zsh-autopair"
	"https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting"
	"https://github.com/marlonrichert/zsh-autocomplete $ZSH_CUSTOM/plugins/zsh-autocomplete"
	"https://github.com/mattmc3/zfunctions $ZSH_CUSTOM/plugins/zfunctions"
	"https://github.com/scaryrawr/fzf.zsh $ZSH_CUSTOM/plugins/fzf"
	"https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab"
	"https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions"
)

# Clone or pull each plugin
for plugin in "${plugins[@]}"; do
	repo_url=$(echo "$plugin" | awk '{print $1}')
	clone_dir=$(echo "$plugin" | awk '{print $2}')
	if [ -d "$clone_dir" ] && [ "$(ls -A $clone_dir)" ]; then
		pushd "$clone_dir" && git pull
		popd
	else
		git clone "$repo_url" "$clone_dir"
	fi
done

sed -i 's/ZSH_THEME=\(.*\)/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

sed -i 's/plugins=\(.*\)/plugins=(gh fast-syntax-highlighting yarn zfunctions zsh-autosuggestions zsh-completions zsh-autopair zoxide fzf-tab fzf eza tmux)/' "$HOME/.zshrc"

# Just append to zshrc if it's not in it.
append_entries=(
	'eval "$(fnm env --use-on-cd --shell zsh)"'
	'# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.'
	'[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
)

for entry in "${append_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.zshrc"; then
		echo "$entry" >> "$HOME/.zshrc"
	fi
done
