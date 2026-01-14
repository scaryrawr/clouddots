#!/usr/bin/env bash

# Ensure bun is available before using it
if ! command -v bun >/dev/null 2>&1; then
  # Try a common Bun installation path if bun is not currently in PATH
  if [ -d "$HOME/.bun/bin" ]; then
    PATH="$HOME/.bun/bin:$PATH"
  fi
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "Error: 'bun' is not installed or not in PATH. Please install Bun before running this script." >&2
  exit 1
fi
if command -v construct >/dev/null 2>&1; then
  echo "construct is already installed; skipping installation."
else
  bun add -g github:scaryrawr/construct
fi
