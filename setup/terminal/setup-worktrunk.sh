#!/usr/bin/env bash
set -e

# Worktrunk shell integration
# This configures worktrunk (wt) to work with bash, zsh, and fish shells
# The integration enables features like auto-cd and shell completions

if ! command -v wt &>/dev/null; then
  echo "worktrunk (wt) not found, skipping shell integration"
  exit 0
fi

# Check if shell integration is already installed by looking for wt function/hook
if grep -q "# wt shell integration" "$HOME/.bashrc" 2>/dev/null || \
   grep -q "# wt shell integration" "$HOME/.zshrc" 2>/dev/null || \
   [ -f "$HOME/.config/fish/functions/wt.fish" ]; then
  echo "Worktrunk shell integration already configured"
  exit 0
fi

# Run worktrunk's shell integration installer non-interactively
# Use 'yes' to automatically answer prompts, with timeout to prevent hanging
# Continue setup even if this fails (some shells may already have integration)
set +e
output=$(timeout 30 bash -c 'yes | wt config shell install' 2>&1)
exit_code=$?
set -e

if [ $exit_code -eq 0 ]; then
  echo "Worktrunk shell integration installed"
else
  echo "Worktrunk shell integration setup failed (exit code: $exit_code)"
  echo "You may need to manually run: wt config shell install"
  # Show output only on failure for debugging
  if [ -n "$output" ]; then
    echo "Output: $output"
  fi
fi
