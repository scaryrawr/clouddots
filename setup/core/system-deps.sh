#!/usr/bin/env bash

# System dependencies installer
# This script can be run multiple times safely (idempotent)
# Automatically upgrades existing binaries to latest versions

export DEBIAN_FRONTEND="noninteractive"

# Bash 4+ required for associative arrays

declare -A bin_to_pkg=(
  [fish]=fish
  [zsh]=zsh
  [file]=file
)

packages=()
for bin in "${!bin_to_pkg[@]}"; do
  if ! command -v "$bin" &>/dev/null; then
    packages+=("${bin_to_pkg[$bin]}")
  fi
done

if command -v apt &>/dev/null; then
  # Enable apt-add-repository
  sudo apt install software-properties-common -y
  sudo add-apt-repository ppa:fish-shell/release-4 -y
  sudo add-apt-repository ppa:git-core/ppa -y

  sudo apt update -y

  # Install packages
  if [ ${#packages[@]} -ne 0 ]; then
    sudo apt install "${packages[@]}" -y
  fi

elif command -v dnf &>/dev/null; then
  if [ ${#packages[@]} -ne 0 ]; then
    sudo dnf update -y
    sudo dnf install --skip-unavailable "${packages[@]}" -y
    sudo dnf install -y git zsh gcc gcc-c++ which unzip jq gh
  fi

else
  echo "Unknown package manager"
  exit 1
fi

# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://bun.sh/install | bash
