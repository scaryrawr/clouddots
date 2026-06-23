#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/pi"

mkdir -p "$HOME/.pi/agents"

agent_file="$HOME/.pi/agents/AGENTS.md"
if [[ ! -f "$agent_file" ]]; then
  cp -f "$config_dir/AGENTS.md" "$agent_file"
fi

pi install git:github.com/scaryrawr/pi-copilot
pi install git:github.com/scaryrawr/pi-local-llm
pi install git:github.com/scaryrawr/pi-automode
pi install git:github.com/scaryrawr/pi-webfetch
