#!/usr/bin/env bash

# Just prepend to bashrc if it's not in it.
prepend_entries=(
  'export PATH="$HOME/.local/share/fnm:$HOME/.npm-global/bin:$HOME/.opencode/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
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
    sed -i "/^export[[:space:]]\+${var_name}=/d; /^${var_name}=/d" "$HOME/.bashrc"
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
      sed -i "/^alias[[:space:]]\+${alias_name}=/d" "$HOME/.bashrc"
    elif [[ "$var_name" =~ \(\)$ ]]; then
      func_name="${var_name%()*}"
      sed -i "/^${func_name}()[[:space:]]*{/,/^}/d" "$HOME/.bashrc"
    else
      sed -i "/^export[[:space:]]\+${var_name}=/d; /^${var_name}=/d" "$HOME/.bashrc"
    fi
  fi
  
  # Add entry at the end (it will be added even if similar entry exists with different value)
  echo "$entry" >>"$HOME/.bashrc"
done
