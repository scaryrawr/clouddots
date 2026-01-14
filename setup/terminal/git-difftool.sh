#!/usr/bin/env bash
# Smart git difftool wrapper - uses VS Code when in VS Code terminal, otherwise delta/diff
# Usage: git-difftool.sh <local> <remote>

LOCAL="$1"
REMOTE="$2"

if [[ -n "$VSCODE_INJECTION" || -n "$TERM_PROGRAM" && "$TERM_PROGRAM" == "vscode" ]]; then
  # In VS Code terminal - use code diff
  exec code --wait --diff "$LOCAL" "$REMOTE"
elif command -v delta &>/dev/null; then
  exec delta "$LOCAL" "$REMOTE"
else
  exec diff "$LOCAL" "$REMOTE"
fi
