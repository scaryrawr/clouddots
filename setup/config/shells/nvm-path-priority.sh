# shellcheck shell=bash
# Keep pre-existing nvm-managed Node paths ahead of Homebrew.
clouddots_prioritize_nvm_node_path() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  local path_entry
  local path_entries=()
  local nvm_paths=""
  local remaining_paths=""

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    # zsh does not split scalar expansions on IFS by default; use its PATH-tied array.
    path_entries=("${path[@]}")
  else
    IFS=: read -r -a path_entries <<< "${PATH:-}"
  fi

  for path_entry in "${path_entries[@]}"; do
    [[ -n "$path_entry" ]] || continue
    case "$path_entry" in
      "$nvm_dir"/versions/node/*/bin|*/versions/node/*/bin)
        if [[ -z "$nvm_paths" ]]; then
          nvm_paths="$path_entry"
        else
          nvm_paths="$nvm_paths:$path_entry"
        fi
        ;;
      *)
        if [[ -z "$remaining_paths" ]]; then
          remaining_paths="$path_entry"
        else
          remaining_paths="$remaining_paths:$path_entry"
        fi
        ;;
    esac
  done

  if [[ -n "$nvm_paths" ]]; then
    if [[ -n "$remaining_paths" ]]; then
      export PATH="$nvm_paths:$remaining_paths"
    else
      export PATH="$nvm_paths"
    fi
  fi
}

clouddots_prioritize_nvm_node_path
unset -f clouddots_prioritize_nvm_node_path
