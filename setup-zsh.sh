#!/usr/bin/env bash

script_dir=$(dirname "$(readlink -f "$0")")

cp "$script_dir/p10k.zsh" "$HOME/.p10k.zsh"
cp "$script_dir/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"

# =============================================================================
# Setup .zshenv for environment variables (loaded before .zshrc, faster startup)
# =============================================================================
zshenv_entries=(
  'export PATH="$HOME/.local/bin:$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
  'export SHELL=${commands[zsh]:-/bin/zsh}'
  'export TMUX_POWERLINE_BUBBLE_SEPARATORS=true'
  'export EDITOR=code'
)

touch "$HOME/.zshenv"

for entry in "${zshenv_entries[@]}"; do
  # Extract variable name from export
  if [[ "$entry" =~ ^export[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="${BASH_REMATCH[1]}"
    # Remove any existing assignment for this variable
    sed -i "/^export[[:space:]]\+${var_name}=/d" "$HOME/.zshenv"
  fi
  # Append the entry
  echo "$entry" >> "$HOME/.zshenv"
done

# =============================================================================
# Clean up old entries that are now in .zshenv
# =============================================================================
# Remove exports that are now in .zshenv
sed -i '/^export PATH=.*fnm.*npm-global.*cargo/d' "$HOME/.zshrc"
sed -i '/^export SHELL=/d' "$HOME/.zshrc"
sed -i '/^export NODE_OPTIONS=/d' "$HOME/.zshrc"
sed -i '/^export TMUX_POWERLINE_BUBBLE_SEPARATORS=/d' "$HOME/.zshrc"

# =============================================================================
# Comment out OMZ
# =============================================================================
sed -i 's/^source \$ZSH\/oh-my-zsh.sh/# source \$ZSH\/oh-my-zsh.sh/' "$HOME/.zshrc"
sed -i 's/^plugins=/# plugins=/' "$HOME/.zshrc"
sed -i 's/^ZSH_THEME=/# ZSH_THEME=/' "$HOME/.zshrc"

# =============================================================================
# Prepend entries to .zshrc (these go after instant prompt, before oh-my-zsh)
# =============================================================================
prepend_entries=(
  'autoload -Uz promptinit && promptinit && prompt powerlevel10k'
  'antidote load'
  '! (( $+functions[antidote] )) && source "$HOME/.antidote/antidote.zsh"'
  '[[ ! -d "$HOME/.antidote" ]] && git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"'
  "zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'"
  "zstyle ':omz:plugins:eza' 'icons' yes"
  "zstyle ':omz:plugins:eza' 'git-status' yes"
  "zstyle ':omz:plugins:eza' 'hyperlink' yes"
  'ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
  'ZSH_TMUX_AUTOSTART=$( [[ -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY$DEVPOD" ]] && echo true || echo false )'
  'ZSH_TMUX_AUTONAME_SESSION=true'
  'ZSH_TMUX_AUTOREFRESH=true'
)

for entry in "${prepend_entries[@]}"; do
  # Build a sed pattern to match existing entries with same key but possibly different value
  if [[ "$entry" =~ ^zstyle[[:space:]]+\'([^\']+)\'[[:space:]]+\'([^\']+)\' ]]; then
    # zstyle: match on context and style name
    sed -i "/^zstyle '${BASH_REMATCH[1]}' '${BASH_REMATCH[2]}'/d" "$HOME/.zshrc"
  elif [[ "$entry" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    # Variable assignment: match on variable name
    sed -i "/^${BASH_REMATCH[1]}=/d" "$HOME/.zshrc"
  else
    # For other entries, use grep -F for literal string matching (no regex issues)
    grep -Fxv "$entry" "$HOME/.zshrc" > "$HOME/.zshrc.tmp" || true
    mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
  fi
  # Prepend entry
  echo "$entry
$(cat $HOME/.zshrc)" >"$HOME/.zshrc"
done

# =============================================================================
# Enable Powerlevel10k instant prompt (must be at very top of .zshrc)
# =============================================================================
INSTANT_PROMPT_CODE='# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'

# Remove any existing instant prompt block and add fresh one at top
sed -i '/# Enable Powerlevel10k instant prompt/,/^fi$/d' "$HOME/.zshrc"
echo "$INSTANT_PROMPT_CODE
$(cat $HOME/.zshrc)" > "$HOME/.zshrc"

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
mkdir -p "$ZSH_CUSTOM"

# Array of plugins to clone
plugins=(
  "https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
  "https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions"
  "https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting"
  "https://github.com/scaryrawr/fzf.zsh $ZSH_CUSTOM/plugins/fzf"
  "https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions"
  "https://github.com/marlonrichert/zsh-autocomplete $ZSH_CUSTOM/plugins/zsh-autocomplete"
  "https://github.com/scaryrawr/p10k-ext $ZSH_CUSTOM/plugins/p10k-ext"
  "https://github.com/scaryrawr/copilot.zsh $ZSH_CUSTOM/plugins/copilot"
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

sed -i 's/plugins=\(.*\)/plugins=(gh fzf p10k-ext fast-syntax-highlighting copilot yarn zsh-autosuggestions zsh-completions zoxide zsh-autocomplete eza tmux)/' "$HOME/.zshrc"

# Just append to zshrc if it's not in it.
append_entries=(
  '(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"'
  '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
  '(( $+commands[nvim] )) && alias vi=nvim'
  '(( $+commands[nvim] )) && alias vim=nvim'
  'alias l="ls -lah"'
  '[[ $- == *i* ]] && stty -ixon < /dev/tty'
)

for entry in "${append_entries[@]}"; do
  grep -qxF "$entry" "$HOME/.zshrc" || echo "$entry" >> "$HOME/.zshrc"
done

#sudo chsh -s $(which zsh) $(whoami)
