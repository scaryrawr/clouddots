#!/usr/bin/env bash

# =============================================================================
# ZSHENV - Environment variables (loaded for ALL shells, before zshrc)
# Moving static exports here speeds up shell startup significantly
# =============================================================================

# Ensure .zshenv exists
touch "$HOME/.zshenv"

# Entries to add to zshenv (idempotent - will update existing or add new)
zshenv_entries=(
  'export PATH="$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"'
  'export TMUX_POWERLINE_BUBBLE_SEPARATORS=true'
)

for entry in "${zshenv_entries[@]}"; do
  # Extract variable name from export statement
  if [[ "$entry" =~ ^export[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="${BASH_REMATCH[1]}"
    # Remove any existing assignment for this variable
    # Note: var_name is alphanumeric so no escaping needed
    sed -i "/^export[[:space:]]\+${var_name}=/d" "$HOME/.zshenv"
  fi
  # Append the entry
  echo "$entry" >> "$HOME/.zshenv"
done

# Add ZSH_TMUX_AUTOSTART detection block (idempotent)
if ! grep -q "ZSH_TMUX_AUTOSTART" "$HOME/.zshenv"; then
  cat >> "$HOME/.zshenv" << 'EOF'

# Detect remote/devpod session once (used by tmux plugin)
if [[ -n "${SSH_CONNECTION}${SSH_CLIENT}${SSH_TTY}${DEVPOD}" ]]; then
  export ZSH_TMUX_AUTOSTART=true
else
  export ZSH_TMUX_AUTOSTART=false
fi
EOF
fi

# =============================================================================
# ZSHRC - Interactive shell config
# =============================================================================

# Clean up old entries that are now in zshenv (from previous script versions)
sed -i '/^export PATH=.*\.local\/share\/fnm/d' "$HOME/.zshrc"
sed -i '/^export SHELL=/d' "$HOME/.zshrc"
sed -i '/^export TMUX_POWERLINE_BUBBLE_SEPARATORS=/d' "$HOME/.zshrc"
sed -i '/^ZSH_TMUX_AUTOSTART=\$(/d' "$HOME/.zshrc"

# Prepend entries to zshrc (after instant prompt, before oh-my-zsh)
prepend_entries=(
  "zstyle ':omz:plugins:eza' 'icons' yes"
  'ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
  'ZSH_TMUX_AUTONAME_SESSION=true'
  'ZSH_TMUX_AUTOREFRESH=true'
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
      # Note: var_name is alphanumeric so no escaping needed
      sed -i "/^export[[:space:]]\+${var_name}=/d; /^${var_name}=/d" "$HOME/.zshrc"
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
  "https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting"
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

sed -i 's/plugins=\(.*\)/plugins=(gh fzf p10k-ext fast-syntax-highlighting copilot yarn zsh-autosuggestions zsh-completions zoxide fzf-tab eza tmux)/' "$HOME/.zshrc"

# =============================================================================
# Ensure p10k instant prompt is at the VERY TOP of .zshrc
# This must come before ANY output or command substitution
# =============================================================================
read -r -d '' instant_prompt_block << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# END p10k instant prompt
EOF

# Remove any existing instant prompt block (using END marker for safety)
sed -i '/# Enable Powerlevel10k instant prompt/,/# END p10k instant prompt/d' "$HOME/.zshrc"
# Also clean up old-style blocks without END marker (first occurrence only)
sed -i '0,/# Enable Powerlevel10k instant prompt/{/# Enable Powerlevel10k instant prompt/,/^fi$/d}' "$HOME/.zshrc"

# Prepend instant prompt block at the very top (using temp file for safety)
tmp_zshrc="$(mktemp)"
{
  echo "${instant_prompt_block}"
  [ -f "$HOME/.zshrc" ] && cat "$HOME/.zshrc"
} > "$tmp_zshrc"
mv "$tmp_zshrc" "$HOME/.zshrc"

# Just append to zshrc if it's not in it.
append_entries=(
  'alias vi=nvim'
  'alias vim=nvim'
  'alias l="ls -lah"'
)

# p10k config sourcing - handle separately to avoid duplicates
sed -i "/# To customize prompt, run.*p10k configure/d" "$HOME/.zshrc"
sed -i "/source.*\.p10k\.zsh/d" "$HOME/.zshrc"
echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> "$HOME/.zshrc"
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"

# Lazy-load fnm - only initialize when node/npm/npx/yarn/pnpm/fnm is first called
# This saves ~50-100ms on shell startup when you don't immediately need node
read -r -d '' fnm_lazy_load << 'EOF'
# Lazy-load fnm (deferred initialization for faster shell startup)
if (( $+commands[fnm] )); then
  _fnm_lazy_load() {
    unfunction node npm npx yarn pnpm fnm 2>/dev/null
    eval "$(fnm env --use-on-cd --shell zsh)"
    "$@"
  }
  node() { _fnm_lazy_load node "$@" }
  npm() { _fnm_lazy_load npm "$@" }
  npx() { _fnm_lazy_load npx "$@" }
  yarn() { _fnm_lazy_load yarn "$@" }
  pnpm() { _fnm_lazy_load pnpm "$@" }
  fnm() { _fnm_lazy_load fnm "$@" }
fi
# END fnm lazy-load
EOF

# Remove old fnm initialization
sed -i '/command -v fnm.*eval.*fnm env/d' "$HOME/.zshrc"
# Remove old lazy-load block if exists (using END marker for safety)
sed -i '/# Lazy-load fnm/,/# END fnm lazy-load/d' "$HOME/.zshrc"

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
      # Note: alias_name is alphanumeric so no escaping needed
      sed -i "/^alias[[:space:]]\+${alias_name}=/d" "$HOME/.zshrc"
    elif [[ "$var_name" =~ \(\)$ ]]; then
      func_name="${var_name%()*}"
      # Note: func_name is alphanumeric so no escaping needed
      # Use awk to properly remove function with brace counting
      awk -v func_name="${func_name}" '
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
      # Note: var_name is alphanumeric so no escaping needed
      sed -i "/^export[[:space:]]\+${var_name}=/d; /^${var_name}=/d" "$HOME/.zshrc"
    fi
  fi

  # Add entry at the end (it will be added even if similar entry exists with different value)
  echo "$entry" >>"$HOME/.zshrc"
done

# Append fnm lazy-load at the end
echo "$fnm_lazy_load" >> "$HOME/.zshrc"

# Disable omz auto-update checks (speeds up startup)
if ! grep -q "zstyle ':omz:update' mode disabled" "$HOME/.zshrc"; then
  echo "zstyle ':omz:update' mode disabled" >> "$HOME/.zshrc"
fi

#sudo chsh -s $(which zsh) $(whoami)
