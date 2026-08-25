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

AGENTS=(github-copilot codex pi opencode)
SKILLS=(skill-creator image-gen better-init code-review blogify azure-devops)

for agent in "${AGENTS[@]}"; do
  for skill in "${SKILLS[@]}"; do
    gh skill install scaryrawr/agentic "$skill" --scope user --agent "$agent" -f
  done

  # Herdr skill is maintained outside scaryrawr/agentic (see .github/copilot-instructions.md).
  gh skill install herdrdev/herdr "skills/herdr" --scope user --agent "$agent" -f
  gh skill install --scope user --agent "$agent" cursor/plugins cursor-team-kit/skills/deslop -f
done
