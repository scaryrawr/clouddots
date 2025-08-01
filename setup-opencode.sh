#!/usr/bin/env bash
set -e

echo "Setting up opencode configuration..."

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/config.json"
AGENTS_DIR="$CONFIG_DIR/agent"

mkdir -p "$CONFIG_DIR"
mkdir -p "$AGENTS_DIR"

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

# Create example agents from the current directory's agents/ subdirectory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"

if [[ -d "$AGENTS_SOURCE_DIR" ]]; then
    echo "Setting up agents from $AGENTS_SOURCE_DIR..."
    
    for agent_file in "$AGENTS_SOURCE_DIR"/*.md; do
        if [[ -f "$agent_file" ]]; then
            agent_name=$(basename "$agent_file")
            target_file="$AGENTS_DIR/$agent_name"
            
            # Only copy if target doesn't exist to avoid overwriting user customizations
            if [[ ! -f "$target_file" ]]; then
                cp "$agent_file" "$target_file"
                echo "  Created agent: $agent_name"
            else
                echo "  Skipped existing agent: $agent_name"
            fi
        fi
    done
else
    echo "No agents directory found at $AGENTS_SOURCE_DIR - skipping agent setup"
fi

echo "opencode agents directory created at $AGENTS_DIR"

