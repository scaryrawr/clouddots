#!/usr/bin/env bash
set -e

# Worktrunk shell integration
# This configures worktrunk (wt) to work with bash, zsh, and fish shells
# The integration enables features like auto-cd and shell completions

if ! command -v wt &>/dev/null; then
  echo "worktrunk (wt) not found, skipping shell integration"
  exit 0
fi

# Run worktrunk's shell integration installer
# This will add the necessary hooks to ~/.bashrc, ~/.zshrc, and fish config
wt config shell install --yes 2>/dev/null || true

echo "Worktrunk shell integration configured"
