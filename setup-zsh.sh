#!/usr/bin/env bash

# Just prepend to zshrc if it's not in it.
prepend_entries=(
  "zstyle ':omz:plugins:eza' 'icons' yes"
  'export PATH="$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
  'export SHELL=$(which zsh)'
  'ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
  'ZSH_TMUX_AUTOSTART=$( [[ -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY$DEVPOD" ]] && echo true || echo false )'
  'ZSH_TMUX_AUTONAME_SESSION=true'
  'ZSH_TMUX_AUTOREFRESH=true'
  'export TMUX_POWERLINE_BUBBLE_SEPARATORS=true'
)

for entry in "${prepend_entries[@]}"; do
  # Extract variable name if this is a variable assignment
  var_name=""
  zstyle_context=""
  zstyle_style=""
  if [[ "$entry" =~ ^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="${BASH_REMATCH[2]}"
  elif [[ "$entry" =~ ^zstyle[[:space:]]+\'([^\']+)\'[[:space:]]+\'([^\']+)\' ]]; then
    # For zstyle commands, match the context and style
    zstyle_context="${BASH_REMATCH[1]}"
    zstyle_style="${BASH_REMATCH[2]}"
    var_name="zstyle '${zstyle_context}' '${zstyle_style}'"
  fi

  # Remove old entries if this is a variable assignment or zstyle
  if [[ -n "$var_name" ]]; then
    if [[ "$entry" =~ ^zstyle ]]; then
      # Remove existing zstyle with same context and style
      sed -i "/^zstyle '${zstyle_context}' '${zstyle_style}'/d" "$HOME/.zshrc"
    else
      # Remove any existing variable assignment (including different values)
      # Escape special regex characters in var_name
      escaped_var_name=$(printf '%s\n' "$var_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
      sed -i "/^export[[:space:]]\+${escaped_var_name}=/d; /^${escaped_var_name}=/d" "$HOME/.zshrc"
    fi
  fi

  # Add entry at the beginning (it will be added even if similar entry exists with different value)
  echo "$entry
$(cat $HOME/.zshrc)" >"$HOME/.zshrc"
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

sed -i 's/plugins=\(.*\)/plugins=(gh fzf p10k-ext fast-syntax-highlighting copilot yarn zfunctions zsh-autosuggestions zsh-completions zsh-autopair zoxide fzf-tab eza tmux)/' "$HOME/.zshrc"

# Just append to zshrc if it's not in it.
append_entries=(
  'command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"'
  '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.'
  '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
  'alias vi=nvim'
  'alias vim=nvim'
  'alias l="ls -lah"'
  'yopilot() { copilot --allow-all-tools "$@"; }'
)

for entry in "${append_entries[@]}"; do
  # Extract variable name if this is a variable assignment or alias
  var_name=""
  if [[ "$entry" =~ ^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="${BASH_REMATCH[2]}"
  elif [[ "$entry" =~ ^alias[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="alias ${BASH_REMATCH[1]}"
  elif [[ "$entry" =~ ^([A-Za-z_][A-Za-z0-9_]*)\(\) ]]; then
    # Function definition
    var_name="${BASH_REMATCH[1]}()"
  fi

  # Remove old entries if this is a variable assignment, alias, or function
  if [[ -n "$var_name" ]]; then
    if [[ "$var_name" =~ ^alias ]]; then
      alias_name="${var_name#alias }"
      # Escape special regex characters in alias_name
      escaped_alias_name=$(printf '%s\n' "$alias_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
      sed -i "/^alias[[:space:]]\+${escaped_alias_name}=/d" "$HOME/.zshrc"
    elif [[ "$var_name" =~ \(\)$ ]]; then
      func_name="${var_name%()*}"
      # Escape special regex characters in func_name
      escaped_func_name=$(printf '%s\n' "$func_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
      # Use awk to properly remove function with brace counting
      awk -v func_name="${escaped_func_name}" '
        BEGIN { in_func=0; brace_count=0 }
        {
          if (in_func == 0 && $0 ~ "^" func_name "\\(\\)[[:space:]]*{") {
            in_func=1
            # Count braces on the function declaration line itself
            brace_count = gsub(/{/, "{", $0)
            brace_count -= gsub(/}/, "}", $0)
            # If braces balance on same line, function is done
            if (brace_count == 0) {
              in_func=0
            }
            next
          }
          if (in_func) {
            brace_count += gsub(/{/, "{")
            brace_count -= gsub(/}/, "}")
            if (brace_count == 0) {
              in_func=0
            }
            next
          }
          print
        }
      ' "$HOME/.zshrc" >"$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
    else
      # Escape special regex characters in var_name
      escaped_var_name=$(printf '%s\n' "$var_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
      sed -i "/^export[[:space:]]\+${escaped_var_name}=/d; /^${escaped_var_name}=/d" "$HOME/.zshrc"
    fi
  fi

  # Add entry at the end (it will be added even if similar entry exists with different value)
  echo "$entry" >>"$HOME/.zshrc"
done

#sudo chsh -s $(which zsh) $(whoami)
