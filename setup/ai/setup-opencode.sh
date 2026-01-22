#!/usr/bin/env bash

mkdir -p "$HOME/.config/opencode"
cat >"$HOME/.config/opencode/opencode.jsonc" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "enabled_providers": ["github-copilot"],
  "share": "disabled",
  "theme": "system",
  "model": "github-copilot/gpt-5.2-codex",
  "small_model": "github-copilot/gpt-5-mini",
  "lsp": {
    "typescript": {
      "disabled": true
    },
    "typescript-native": {
      "command": ["tsgo", "--lsp", "--stdio"],
      "extensions": [".ts", ".tsx", ".js", ".jsx", ".mts", ".cts", ".cjs", ".mjs"]
    }
  }
}
EOF
