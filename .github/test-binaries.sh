#!/usr/bin/env bash
set -e

# Test script to validate that binaries installed via Homebrew work correctly

echo "Testing installed binaries..."

# Source profile to ensure PATH includes ~/.local/bin
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

# Array of binaries installed via Homebrew and their test commands
declare -A binary_tests=(
  [bat]="bat --version"
  [fd]="fd --version"
  [fzf]="fzf --version"
  [eza]="eza --version"
  [zoxide]="zoxide --version"
  [delta]="delta --version"
)

failed_tests=()

for binary in "${!binary_tests[@]}"; do
  echo -n "Testing $binary... "

  if command -v "$binary" &>/dev/null; then
    if eval "${binary_tests[$binary]}" &>/dev/null; then
      echo "✓"
    else
      echo "✗ (command exists but test failed)"
      failed_tests+=("$binary")
    fi
  else
    echo "✗ (not found)"
    failed_tests+=("$binary")
  fi
done

echo
if [ ${#failed_tests[@]} -eq 0 ]; then
  echo "All binary tests passed! ✓"
  exit 0
else
  echo "Failed tests for: ${failed_tests[*]}"
  exit 1
fi

