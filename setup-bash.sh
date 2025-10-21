#!/usr/bin/env bash

# Just prepend to bashrc if it's not in it.
prepend_entries=(
  'export PATH="$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
  'export SHELL=$(which bash)'
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
  'command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell bash)"'
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
  
  # Add entry at the end (it will be added even if similar entry exists with different value)
  echo "$entry" >>"$HOME/.bashrc"
done
