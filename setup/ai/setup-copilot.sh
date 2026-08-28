#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/copilot"

discover_repository_roots() {
  local search_root candidate repository_root
  local -a search_roots=("/workspaces")
  local -a repository_roots=()
  local -A seen_roots=()

  command -v git &>/dev/null || return 0

  for search_root in "${search_roots[@]}"; do
    [[ -d "$search_root" ]] || continue

    while IFS= read -r -d '' candidate; do
      [[ -d "$candidate/.git" || -f "$candidate/.git" ]] || continue

      if ! repository_root="$(
        git -c "safe.directory=$candidate" \
          -C "$candidate" rev-parse --show-toplevel 2>/dev/null
      )"; then
        continue
      fi
      [[ "$repository_root" != *$'\n'* && "$repository_root" != *$'\r'* ]] || continue
      if ! repository_root="$(cd "$repository_root" && pwd -P)"; then
        continue
      fi
      [[ -n "${seen_roots[$repository_root]+present}" ]] && continue

      seen_roots["$repository_root"]=1
      repository_roots+=("$repository_root")
    done < <(find -L "$search_root" -mindepth 1 -maxdepth 1 -type d -print0)
  done

  if ((${#repository_roots[@]} > 0)); then
    printf '%s\n' "${repository_roots[@]}" | LC_ALL=C sort
  fi
}

write_copilot_instructions() {
  local destination="$HOME/.copilot/copilot-instructions.md"
  local temporary_file repository_root
  local -a repository_roots=()

  while IFS= read -r repository_root; do
    repository_roots+=("$repository_root")
  done < <(discover_repository_roots)

  temporary_file="$(mktemp "$destination.XXXXXX")"
  trap 'rm -f -- "$temporary_file"' EXIT RETURN

  {
    printf '%s\n\n' '# Local Git repository roots'
    if ((${#repository_roots[@]} > 0)); then
      printf '%s\n\n' 'Git repository roots available on this machine:'
      printf '    %s\n' "${repository_roots[@]}"
    else
      printf '%s\n' 'No Git repositories were found in the standard workspace locations.'
    fi
  } >"$temporary_file"

  mv -f "$temporary_file" "$destination"
  trap - EXIT RETURN
}

mkdir -p "$HOME/.copilot"

config_file="$HOME/.copilot/settings.json"
dotfiles_settings="$config_dir/settings.json"
if [[ -f "$config_file" ]]; then
  # Merge dotfiles settings into the existing settings, letting dotfiles values win.
  tmp_settings="$(mktemp)"
  jq -s '.[0] * .[1] | del(.enabledPlugins["copilot@scarypilot"])' \
    "$config_file" "$dotfiles_settings" >"$tmp_settings"
  mv "$tmp_settings" "$config_file"
else
  cp -f "$dotfiles_settings" "$config_file"
fi

write_copilot_instructions
cp -f "$config_dir/lsp-config.json" "$HOME/.copilot/lsp-config.json"

legacy_extension_dir="$HOME/.copilot/extensions/copilot-local-llm"
if [[ -d "$legacy_extension_dir" ]]; then
  rm -rf -- "$legacy_extension_dir"
fi
