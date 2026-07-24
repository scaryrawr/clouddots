#!/usr/bin/env bash
set -e

if ! command -v herdr >/dev/null 2>&1; then
  echo "Herdr is required before installing agent integrations." >&2
  exit 1
fi

mkdir -p "$HOME/.pi/agent/extensions" "$HOME/.copilot/hooks"

herdr integration install pi
herdr integration install copilot
