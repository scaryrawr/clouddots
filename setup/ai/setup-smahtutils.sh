#!/usr/bin/env bash

cargo install --git https://github.com/scaryrawr/smahtutils smahties

mkdir -p "$HOME/.wickedsmaht"

cat >"$HOME/.wickedsmaht/config.json" <<'EOF'
{
  "base_url": "http://127.0.0.1:14892/v1",
  "model": "Qwen3.5-9B-mxfp8",
  "coding-embedding-model": "CodeRankEmbed-mxpf4"
}
EOF
