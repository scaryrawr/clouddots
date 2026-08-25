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

copilot_skills=(skill-creator better-init code-review)

for skill in "${copilot_skills[@]}"; do
  gh skill install scaryrawr/agentic "$skill" --scope user --agent github-copilot -f
done

# Herdr skill is maintained outside scaryrawr/agentic (see .github/copilot-instructions.md).
gh skill install herdrdev/herdr "skills/herdr" --scope user --agent github-copilot -f
gh skill install --scope user --agent github-copilot cursor/plugins cursor-team-kit/skills/deslop -f
