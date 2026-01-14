#!/usr/bin/env bash
set -e
# Smart git mergetool wrapper - uses VS Code when in VS Code terminal, otherwise nvim
# Usage: git-mergetool.sh <remote> <local> <base> <merged>

# Validate required arguments
if [[ $# -ne 4 ]]; then
  echo "Error: Expected 4 arguments, got $#" >&2
  echo "Usage: git-mergetool.sh <remote> <local> <base> <merged>" >&2
  exit 1
fi

REMOTE="$1"
LOCAL="$2"
BASE="$3"
MERGED="$4"

# Validate all arguments are non-empty
if [[ -z "$REMOTE" || -z "$LOCAL" || -z "$BASE" || -z "$MERGED" ]]; then
  echo "Error: All arguments must be non-empty" >&2
  echo "Usage: git-mergetool.sh <remote> <local> <base> <merged>" >&2
  exit 1
fi

if [[ -n "$VSCODE_INJECTION" || -n "$TERM_PROGRAM" && "$TERM_PROGRAM" == "vscode" ]]; then
  # In VS Code terminal - use code merge
  exec code --wait --merge "$REMOTE" "$LOCAL" "$BASE" "$MERGED"
elif command -v nvim &>/dev/null; then
  # Use nvim with diff mode for merge
  exec nvim -d "$LOCAL" "$REMOTE" "$BASE" -c "wincmd J" -c "wincmd =" "$MERGED"
elif command -v hx &>/dev/null; then
  exec hx "$MERGED"
elif command -v vim &>/dev/null; then
  exec vim -d "$LOCAL" "$REMOTE" "$MERGED"
else
  exec vi "$MERGED"
fi
