#!/bin/bash

set -e

echo "Setting up opencode configuration..."

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/config.json"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "system",
  "layout": "stretch",
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
echo "Configuration includes:"
echo "  - Sequential thinking MCP server"
echo "  - System theme with stretch layout"