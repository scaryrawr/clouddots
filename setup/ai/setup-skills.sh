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
SKILLS=(skill-creator image-gen better-init)

# Only install Azure DevOps skills if the repo origin is an Azure DevOps URL.
# These skills replace the former scaryrawr/scarypilot azure-devops plugin.
origin_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$origin_url" == *"dev.azure.com/"* ]] || [[ "$origin_url" == *".visualstudio.com/"* ]] || [[ "$origin_url" == *"ssh.dev.azure.com:"* ]]; then
  SKILLS+=(ado-cli ado-pr ado-work-items ado-make-pr ado-review-pr)
fi

for skill in "${SKILLS[@]}"; do
  for agent in "${AGENTS[@]}"; do
    gh skill install scaryrawr/agentic "$skill" --scope user --agent "$agent" -f
  done
done
