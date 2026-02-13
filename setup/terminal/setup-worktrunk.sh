#!/usr/bin/env bash
set -e

# Worktrunk shell integration
# This configures worktrunk (wt) to work with bash, zsh, and fish shells
# The integration enables features like auto-cd and shell completions

# Timeout for shell integration installation (prevents hanging on interactive prompts)
INSTALL_TIMEOUT=30

if ! command -v wt &>/dev/null; then
  echo "worktrunk not found, skipping shell integration"
  exit 0
fi

# Check if shell integration is already installed
# Look for wt function/hooks in shell configs or config files
if grep -qE "(function wt|wt\s*\(\))" "$HOME/.bashrc" 2>/dev/null || \
   grep -qE "(function wt|wt\s*\(\))" "$HOME/.zshrc" 2>/dev/null || \
   [ -f "$HOME/.config/fish/functions/wt.fish" ]; then
  echo "Worktrunk shell integration already configured"
  exit 0
fi

# Run worktrunk's shell integration installer non-interactively
# Use 'yes' to automatically answer prompts, with timeout to prevent hanging
# Continue setup even if this fails (some shells may already have integration)
set +e
output=$(timeout "$INSTALL_TIMEOUT" yes | wt config shell install 2>&1)
exit_code=$?
set -e

if [ $exit_code -eq 0 ]; then
  echo "Worktrunk shell integration installed"
elif [ $exit_code -eq 124 ]; then
  echo "Worktrunk shell integration setup timed out after ${INSTALL_TIMEOUT} seconds"
  echo "You may need to manually run: wt config shell install"
else
  echo "Worktrunk shell integration setup failed (exit code: $exit_code)"
  echo "You may need to manually run: wt config shell install"
  # Show output only on failure for debugging
  if [ -n "$output" ]; then
    echo "Output: $output"
  fi
fi
