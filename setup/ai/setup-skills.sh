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

AGENTS=(github-copilot claude-code codex pi opencode)
SKILLS=(skill-creator image-gen)
for skill in "${SKILLS[@]}"; do
  for agent in "${AGENTS[@]}"; do
    gh skill install scaryrawr/agentic "$skill" --scope user --agent "$agent" -f
  done
done
