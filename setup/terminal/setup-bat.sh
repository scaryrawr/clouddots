#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.config/bat"
cat >"$HOME/.config/bat/config" <<'EOF'
--theme="ansi"
EOF
