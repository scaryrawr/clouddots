#!/usr/bin/env bash

cat >"$HOME/.config/opencode/opencode.jsonc" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "enabled_providers": ["github-copilot"],
  "share": "disabled",
  "theme": "system",
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
