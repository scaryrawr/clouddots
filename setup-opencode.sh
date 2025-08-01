#!/usr/bin/env bash
set -e

echo "Setting up opencode configuration..."

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/config.json"

mkdir -p "$CONFIG_DIR"

cat >"$CONFIG_FILE" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "system",
  "layout": "stretch",
  "share": "disabled",
  "mcp": {
    "sequential-thinking": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
EOF

echo "opencode configuration created at $CONFIG_FILE"
