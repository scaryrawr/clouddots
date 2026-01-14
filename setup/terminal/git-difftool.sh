#!/usr/bin/env bash
set -e
# Smart git difftool wrapper - uses VS Code when in VS Code terminal, otherwise delta/diff
# Usage: git-difftool.sh <local> <remote>

# Validate required arguments
if [[ $# -ne 2 ]]; then
  echo "Error: Expected 2 arguments, got $#" >&2
  echo "Usage: git-difftool.sh <local> <remote>" >&2
  exit 1
fi

LOCAL="$1"
REMOTE="$2"

# Validate all arguments are non-empty
if [[ -z "$LOCAL" || -z "$REMOTE" ]]; then
  echo "Error: All arguments must be non-empty" >&2
  echo "Usage: git-difftool.sh <local> <remote>" >&2
  exit 1
fi

if [[ -n "$VSCODE_INJECTION" || -n "$TERM_PROGRAM" && "$TERM_PROGRAM" == "vscode" ]]; then
  # In VS Code terminal - use code diff
  exec code --wait --diff "$LOCAL" "$REMOTE"
elif command -v delta &>/dev/null; then
  exec delta "$LOCAL" "$REMOTE"
else
  exec diff "$LOCAL" "$REMOTE"
fi
