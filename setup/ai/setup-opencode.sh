#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.config/opencode"

cat >"$HOME/.config/opencode/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "share": "disabled"
}
EOF
