#!/usr/bin/env bash
set -e

touch "$HOME/.bashrc"

# Just prepend to bashrc if it's not in it.
prepend_entries=(
  'export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.bun/bin:$PATH"'
  'export SHELL=$(which bash)'
  '[[ -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY$DEVPOD" ]] && export BROWSER="$HOME/browser-opener.sh"'
)

for entry in "${prepend_entries[@]}"; do
  # Extract variable name if this is a variable assignment
  var_name=""
  if [[ "$entry" =~ ^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)= ]]; then
    var_name="${BASH_REMATCH[2]}"
  fi
  
  # Remove old entries if this is a variable assignment
  if [[ -n "$var_name" ]]; then
    # Escape special regex characters in var_name
    escaped_var_name=$(printf '%s\n' "$var_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
    sed -i "/^export[[:space:]]\+${escaped_var_name}=/d; /^${escaped_var_name}=/d" "$HOME/.bashrc"
  fi
  
  # Add entry at the beginning (it will be added even if similar entry exists with different value)
  echo "$entry
$(cat $HOME/.bashrc)" >"$HOME/.bashrc"
done

# Just append to bashrc if it's not in it.
append_entries=(
  '[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  '[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"'
  'command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell bash)"'
  'az() { AZURE_DEVOPS_EXT_PAT=$(ado-auth-helper get-access-token) command az "$@"; }'
  '[ -f "$HOME/notification-sender.sh" ] && source "$HOME/notification-sender.sh"'
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
      sed -i "/^alias[[:space:]]\+${escaped_alias_name}=/d" "$HOME/.bashrc"
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
            brace_count=1
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
      ' "$HOME/.bashrc" > "$HOME/.bashrc.tmp" && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
    else
      # Escape special regex characters in var_name
      escaped_var_name=$(printf '%s\n' "$var_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
      sed -i "/^export[[:space:]]\+${escaped_var_name}=/d; /^${escaped_var_name}=/d" "$HOME/.bashrc"
    fi
  fi
  
  # Add entry at the end if not already present
  grep -Fxq "$entry" "$HOME/.bashrc" || echo "$entry" >>"$HOME/.bashrc"
done

# =============================================================================
# Setup BASH_ENV for non-interactive shells
# =============================================================================
# Check if BASH_ENV is set to the desired value, if not set it to ~/.bashenv
bashenv_file="$HOME/.bashenv"
if ! grep -q "^export BASH_ENV=\"$bashenv_file\"$" "$HOME/.bashrc"; then
  # Remove any existing BASH_ENV export first
  sed -i "/^export BASH_ENV=/d" "$HOME/.bashrc"
  echo "export BASH_ENV=\"$bashenv_file\"" >> "$HOME/.bashrc"
fi

# Create bashenv file if it doesn't exist
touch "$bashenv_file"

# Add az function to BASH_ENV file
az_function='az() { AZURE_DEVOPS_EXT_PAT=$(ado-auth-helper get-access-token) command az "$@"; }'
if ! grep -Fxq "$az_function" "$bashenv_file"; then
  # Remove any existing az function (both single-line and multi-line)
  awk '
    BEGIN { in_func=0; brace_count=0 }
    {
      # Match function definition: az() { ... (double backslash needed for awk regex)
      # Also handles optional leading whitespace
      if (in_func == 0 && $0 ~ "^[[:space:]]*az\\(\\)[[:space:]]*{") {
        # Count braces on this line
        line = $0
        open_braces = gsub(/{/, "{", line)
        close_braces = gsub(/}/, "}", line)
        if (open_braces == close_braces) {
          # Single-line function, skip it
          next
        } else {
          # Multi-line function starts
          in_func=1
          brace_count = open_braces - close_braces
          next
        }
      }
      if (in_func) {
        line = $0
        brace_count += gsub(/{/, "{", line)
        brace_count -= gsub(/}/, "}", line)
        if (brace_count == 0) {
          in_func=0
        }
        next
      }
      print
    }
  ' "$bashenv_file" > "$bashenv_file.tmp" && mv "$bashenv_file.tmp" "$bashenv_file"
  
  # Add the az function
  echo "$az_function" >> "$bashenv_file"
fi

# =============================================================================
# Codespace SSH environment loading (mirrors codespaces.fish)
# =============================================================================
cs_start="# >>> codespace-env >>>"
cs_end="# <<< codespace-env <<<"

for target_file in "$HOME/.bashrc" "$bashenv_file"; do
  # Remove existing block if present
  if grep -qF "$cs_start" "$target_file" 2>/dev/null; then
    awk -v start="$cs_start" -v end="$cs_end" '
      $0 == start { skip=1; next }
      $0 == end { skip=0; next }
      !skip
    ' "$target_file" > "$target_file.tmp" && mv "$target_file.tmp" "$target_file"
  fi

  cat >> "$target_file" << 'CSEOF'
# >>> codespace-env >>>
if [[ -n "$SSH_CONNECTION" && -f /workspaces/.codespaces/shared/.env-secrets ]]; then
  while IFS= read -r line; do
    key="${line%%=*}"
    value="${line#*=}"
    decoded_value="$(echo "$value" | base64 -d 2>/dev/null)" || continue
    if [[ "$key" == "PATH" ]]; then
      # Merge PATH — append entries not already present so shell-managed paths keep priority
      IFS=: read -ra env_paths <<< "$decoded_value"
      for p in "${env_paths[@]}"; do
        [[ -n "$p" && ":$PATH:" != *":$p:"* ]] && export PATH="$PATH:$p"
      done
    else
      export "$key=$decoded_value"
    fi
  done < /workspaces/.codespaces/shared/.env-secrets
fi
# <<< codespace-env <<<
CSEOF
done
