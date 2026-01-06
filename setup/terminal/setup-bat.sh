#!/usr/bin/env bash

mkdir -p "$HOME/.config/bat"
cat >"$HOME/.config/bat/config" <<'EOF'
--theme="ansi"
EOF
