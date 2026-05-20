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

skill_installed() {
  gh skill list 2>/dev/null | grep -Eq "(^|[[:space:]])$1([[:space:]]|$)"
}

if ! skill_installed "skill-creator"; then
  gh skill install scaryrawr/agentic skill-creator --scope user --agent pi --agent copilot --agent codex --agent claude-code
fi

if ! skill_installed "image-gen"; then
  gh skill install scaryrawr/agentic image-gen --scope user --agent pi --agent copilot --agent codex --agent claude-code
fi
