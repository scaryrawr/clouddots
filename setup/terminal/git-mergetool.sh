#!/usr/bin/env bash
# Smart git mergetool wrapper - uses VS Code when in VS Code terminal, otherwise nvim
# Usage: git-mergetool.sh <remote> <local> <base> <merged>

REMOTE="$1"
LOCAL="$2"
BASE="$3"
MERGED="$4"

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
