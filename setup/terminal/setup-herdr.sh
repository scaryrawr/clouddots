#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/herdr"

mkdir -p "$HOME/.config/herdr"
cp -f "$config_dir/config.toml" "$HOME/.config/herdr/config.toml"

plugin_id="scaryrawr.agent-title"
plugin_source="scaryrawr/herdr-agent-title"

plugin_is_installed() {
  local plugins

  if ! plugins=$(herdr plugin list --plugin "$plugin_id" --json); then
    return 1
  fi

  grep -Eq "\"plugin_id\"[[:space:]]*:[[:space:]]*\"$plugin_id\"" <<<"$plugins"
}

if ! plugin_is_installed; then
  for attempt in 1 2 3; do
    if herdr plugin install "$plugin_source" --yes && plugin_is_installed; then
      break
    fi

    if [[ $attempt -lt 3 ]]; then
      echo "Herdr plugin installation failed; retrying ($attempt/3)..." >&2
      sleep 2
    fi
  done
fi

if ! plugin_is_installed; then
  echo "Unable to install Herdr plugin: $plugin_source" >&2
  exit 1
fi
