#!/usr/bin/env bash
# Smart git editor wrapper - uses VS Code when in VS Code terminal, otherwise nvim/helix
# Usage: git-editor.sh <file>

if [[ -n "$VSCODE_INJECTION" || -n "$TERM_PROGRAM" && "$TERM_PROGRAM" == "vscode" ]]; then
  # In VS Code terminal - use code with wait flag
  exec code --wait "$@"
elif command -v nvim &>/dev/null; then
  exec nvim "$@"
elif command -v hx &>/dev/null; then
  exec hx "$@"
elif command -v vim &>/dev/null; then
  exec vim "$@"
else
  exec vi "$@"
fi
