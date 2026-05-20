#!/usr/bin/env bash

# setup playwright skills globally
(
  cd "$HOME"
  playwright-cli install --skills agents
)

mkdir -p "$HOME/.playwright"
cat >"$HOME/.playwright/cli.config.json" <<'EOF'
{
  "browser": {
    "browserName": "chromium",
    "cdpEndpoint": "http://127.0.0.1:9222"
  }
}
EOF
