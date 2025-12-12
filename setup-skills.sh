#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$HOME/.claude"

SKILLS_DIR="$HOME/.claude/skills"
SKILLS_REPO="https://github.com/scaryrawr/skillz"

if [[ ! -d "$SKILLS_DIR" ]]; then
	git clone "$SKILLS_REPO" "$SKILLS_DIR"
else
	if [[ -d "$SKILLS_DIR/.git" ]]; then
		git -C "$SKILLS_DIR" pull --ff-only
	else
		echo "Error: $SKILLS_DIR exists but is not a git repository" >&2
		exit 1
	fi
fi

