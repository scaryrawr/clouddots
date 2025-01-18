#!/usr/bin/env bash

# Just prepend to zshrc if it's not in it.
prepend_entries=(
	"zstyle ':omz:plugins:eza' 'icons' yes"
)

for entry in "${prepend_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.zshrc"; then
		echo "$entry
$(cat $HOME/.zshrc)" >$HOME/.zshrc
	fi
done

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
mkdir -p $ZSH_CUSTOM

# Install zsh plugins
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/hlissner/zsh-autopair $ZSH_CUSTOM/plugins/zsh-autopair
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
git clone https://github.com/marlonrichert/zsh-autocomplete $ZSH_CUSTOM/plugins/zsh-autocomplete
git clone https://github.com/mattmc3/zfunctions $ZSH_CUSTOM/plugins/zfunctions
git clone https://github.com/scaryrawr/fzf.zsh $ZSH_CUSTOM/plugins/fzf
git clone https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab

sed -i 's/ZSH_THEME=\(.*\)/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $HOME/.zshrc

sed -i 's/plugins=\(.*\)/plugins=(brew gh fast-syntax-highlighting yarn zfunctions zsh-autosuggestions zsh-autopair zoxide fzf-tab fzf eza)/' $HOME/.zshrc

# Just append to zshrc if it's not in it.
append_entries=(
	'# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.'
	'[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
)

for entry in "${append_entries[@]}"; do
	if ! grep -q "$entry" "$HOME/.zshrc"; then
		echo "$entry" >>$HOME/.zshrc
	fi
done
