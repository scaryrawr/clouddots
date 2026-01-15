#!/usr/bin/env bash

cat >"$HOME/.config/opencode/opencode.jsonc" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "enabled_providers": ["github-copilot"],
  "share": "disabled",
  "theme": "system"
}
EOF
