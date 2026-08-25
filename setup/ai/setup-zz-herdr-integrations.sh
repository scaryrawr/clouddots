#!/usr/bin/env bash
set -e

if ! command -v herdr >/dev/null 2>&1; then
  echo "Herdr is required before installing the Copilot integration." >&2
  exit 1
fi

mkdir -p "$HOME/.copilot/hooks"

herdr integration install copilot
