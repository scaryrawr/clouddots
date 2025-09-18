#!/usr/bin/env bash

# System dependencies installer
# This script can be run multiple times safely (idempotent)
# Automatically upgrades existing binaries to latest versions

export DEBIAN_FRONTEND="noninteractive"

# Bash 4+ required for associative arrays

declare -A bin_to_pkg=(
  [fish]=fish
  [zsh]=zsh
  [rg]=ripgrep
  [hx]=helix
  [fzf]=fzf
  [file]=file
  [chafa]=chafa
  [bat]=bat
  [fd]=fd-find
  [tmux]=tmux
  [nvim]=neovim
)

packages=()
for bin in "${!bin_to_pkg[@]}"; do
  if ! command -v "$bin" &>/dev/null; then
    packages+=("${bin_to_pkg[$bin]}")
  fi
done

if command -v apt &>/dev/null; then
  sudo apt update -y

  for i in "${!packages[@]}"; do
    if [[ "${packages[i]}" == "fzf" ]]; then
      # Remove fzf from packages since we'll install it from binary
      unset packages[i]
    fi
  done

  # Enable apt-add-repository
  sudo apt install software-properties-common -y
  sudo add-apt-repository ppa:fish-shell/release-4 -y
  sudo add-apt-repository ppa:git-core/ppa -y
  sudo add-apt-repository ppa:maveonair/helix-editor -y
  sudo sudo add-apt-repository ppa:neovim-ppa/unstable -y

  sudo apt update -y
  sudo apt upgrade -y

  # Install and upgrade packages
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

# Shared install logic for all platforms

# Detect architecture and create flexible pattern
arch=$(uname -m)
case "$arch" in
x86_64 | amd64) arch_pattern="(x86_64|amd64|x64)" ;;
aarch64 | arm64) arch_pattern="(aarch64|arm64)" ;;
*) echo "Unsupported architecture: $arch" && exit 1 ;;
esac

# Helper function to ensure ~/.local/bin is in PATH
ensure_local_bin_in_path() {
  if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.profile"
  fi
}

# Helper function to get download URL from GitHub releases
get_github_release_url() {
  local repo="$1"
  local asset_pattern="$2"
  local download_url

  # Try GitHub CLI first (fetch raw JSON, then pipe to jq)
  if command -v gh &>/dev/null; then
    download_url=$(gh api "repos/$repo/releases/latest" | jq -r --arg pattern "$asset_pattern" '.assets[] | select(.name | test($pattern)) | .browser_download_url' | head -1)
  fi

  # Fallback to curl if gh failed or isn't available
  if [[ -z "$download_url" || "$download_url" == "null" ]]; then
    download_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r --arg pattern "$asset_pattern" '.assets[] | select(.name | test($pattern)) | .browser_download_url' | head -1)
  fi

  echo "$download_url"
}

# Function to download and install binary releases
install_binary_release() {
  local tool="$1"
  local repo="$2"
  local asset_pattern="$3"
  local binary_name="${4:-$tool}" # Default to tool name if not specified

  if command -v "$binary_name" &>/dev/null; then
    echo "Upgrading $tool to latest version..."
  else
    echo "Installing $tool from binary release..."
  fi

  local temp_dir="/tmp/$tool-install"
  trap "rm -rf '$temp_dir'" EXIT

  local download_url
  download_url=$(get_github_release_url "$repo" "$asset_pattern")

  if [[ -z "$download_url" || "$download_url" == "null" ]]; then
    echo "Could not find binary release for $tool"
    return 1
  fi

  mkdir -p "$temp_dir" "$HOME/.local/bin"
  local filename=$(basename "$download_url")

  curl -L "$download_url" -o "$temp_dir/$filename" || {
    echo "Failed to download $tool"
    return 1
  }

  # Extract archive
  case "$filename" in
  *.tar.gz | *.tar.xz) tar -xf "$temp_dir/$filename" -C "$temp_dir" ;;
  *.zip) unzip -q "$temp_dir/$filename" -d "$temp_dir" ;;
  *) cp "$temp_dir/$filename" "$HOME/.local/bin/$binary_name" && chmod +x "$HOME/.local/bin/$binary_name" && ensure_local_bin_in_path && echo "$tool installed successfully" && return 0 ;;
  esac

  # Find and install binary
  local extracted_binary=$(find "$temp_dir" -name "$binary_name" -type f -executable | head -1)
  if [[ -z "$extracted_binary" ]]; then
    echo "Could not find $binary_name in extracted archive"
    return 1
  fi

  cp "$extracted_binary" "$HOME/.local/bin/$binary_name"
  chmod +x "$HOME/.local/bin/$binary_name"
  ensure_local_bin_in_path
  echo "$tool installed successfully"
}

# Install tools from binary releases
install_binary_release "fzf" "junegunn/fzf" "fzf.*linux.*${arch_pattern}.*\\.tar\\.gz$"
install_binary_release "eza" "eza-community/eza" "eza.*${arch_pattern}.*linux.*\\.tar\\.gz$"
install_binary_release "delta" "dandavison/delta" "delta.*-${arch_pattern}.*linux.*\\.tar\\.gz$"
install_binary_release "lazygit" "jesseduffield/lazygit" "lazygit.*Linux.*${arch_pattern}.*\\.tar\\.gz$"
install_binary_release "magus" "scaryrawr/magus" "magus-linux-${arch_pattern}\\.tar\\.gz$"

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -fsSL https://opencode.ai/install | bash

# Handle bat/batcat symlink for apt installations
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  echo "Creating bat symlink to batcat..."
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
  echo "Created bat symlink successfully"
fi
