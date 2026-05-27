#!/usr/bin/env bash
set -e

if ! command -v gh >/dev/null 2>&1; then
  echo "Skipping skill setup: gh is not installed."
  exit 0
fi

if ! gh skill --help >/dev/null 2>&1; then
  echo "Skipping skill setup: installed gh does not support 'gh skill'."
  exit 0
fi

gh skill install scaryrawr/agentic skill-creator --scope user --agent github-copilot --agent claude-code --agent codex --agent pi --agent opencode -f
gh skill install scaryrawr/agentic image-gen --scope user --agent github-copilot --agent claude-code --agent codex --agent pi --agent opencode -f
