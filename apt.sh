#!/usr/bin/env bash

export DEBIAN_FRONTEND="noninteractive"

declare -A package_map=(
	["fish"]="fish"
	["zsh"]="zsh"
	["rg"]="ripgrep"
	["fzf"]="fzf"
	["file"]="file"
	["chafa"]="chafa"
	["bat"]="bat"
	["eza"]="eza"
	["fd"]="fd-find"
	["tmux"]="tmux"
)

# Remove packages that are already installed
for binary in "${!package_map[@]}"; do
	if command -v "$binary" &>/dev/null; then
		unset 'package_map["$binary"]'
	fi
done

# Convert associative array to indexed array
packages=("${package_map[@]}")

if command -v apt &>/dev/null; then
	for i in "${!packages[@]}"; do
		if [[ "${packages[i]}" == "fzf" ]]; then
			packages[i]="golang-go"
		fi
	done

	# Enable apt-add-repository
	sudo apt install software-properties-common -y

	# Add fish shell repository
	if [[ " ${packages[*]} " =~ " fish " ]]; then
		sudo add-apt-repository ppa:fish-shell/release-4 -y
	fi

	sudo add-apt-repository ppa:git-core/ppa -y

	# Add Go repository if golang-go is in the packages to install
	if [[ " ${packages[*]} " =~ " golang-go " ]]; then
		sudo add-apt-repository ppa:longsleep/golang-backports -y
	fi

	sudo apt update -y
	sudo apt upgrade -y

	# Install and upgrade packages
	if [ ${#packages[@]} -ne 0 ]; then
		sudo apt install "${packages[@]}" -y
	fi

	# Install fzf from source
	command -v go && go install github.com/junegunn/fzf@latest


elif command -v dnf &>/dev/null; then
	if [ ${#packages[@]} -ne 0 ]; then
		sudo dnf update -y
		sudo dnf install --skip-unavailable "${packages[@]}" -y
	fi


else
	echo "Unknown package manager"
	exit 1
fi

# Shared install logic for all platforms

# Ensure rust/cargo is installed via rustup if not present
if ! command -v cargo &>/dev/null; then
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	. "$HOME/.cargo/env"
	if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' "$HOME/.profile"; then
		echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.profile"
	fi
fi


# Install eza, zoxide, delta via cargo if not present or outdated
if ! command -v eza &>/dev/null; then
	cargo install eza
fi
# Install helix from latest git if not present or outdated
if ! command -v hx &>/dev/null; then
	cargo install --git https://github.com/helix-editor/helix helix-term --locked
else
	INSTALLED_VERSION=$(hx --version | awk '{print $2}')
	LATEST_VERSION=$(cargo search helix-term | grep '^helix-term =' | awk -F '"' '{print $2}' | head -n1)
	if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
		cargo install --git https://github.com/helix-editor/helix helix-term --locked
	fi
fi
# Install zoxide via cargo if not present or outdated
if ! command -v zoxide &>/dev/null; then
	cargo install zoxide --locked
else
	INSTALLED_VERSION=$(zoxide --version | awk '{print $2}')
	LATEST_VERSION=$(cargo search zoxide | grep '^zoxide =' | awk -F '"' '{print $2}' | head -n1)
	if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
		cargo install zoxide --locked
	fi
fi
# Install delta via cargo if not present or outdated
if ! command -v delta &>/dev/null; then
	cargo install git-delta --locked
else
	INSTALLED_VERSION=$(delta --version | awk '{print $2}')
	LATEST_VERSION=$(cargo search git-delta | grep '^git-delta =' | awk -F '"' '{print $2}' | head -n1)
	if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
		cargo install git-delta --locked
	fi
fi

# Download and install latest Zig release for Linux (x86_64 and aarch64)
if ! command -v zig &>/dev/null; then
	ZIG_VERSION="0.14.1"
	arch=$(uname -m)
	case "$arch" in
		x86_64|amd64)
			zig_arch="x86_64"
			;;
		aarch64|arm64)
			zig_arch="aarch64"
			;;
		*)
			echo "Unsupported architecture for Zig: $arch"; exit 1
			;;
	esac
	zig_url="https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${zig_arch}-${ZIG_VERSION}.tar.xz"
	tmp_dir=$(mktemp -d)
	wget "$zig_url" -O "$tmp_dir/zig.tar.xz"
	tar -xf "$tmp_dir/zig.tar.xz" -C "$tmp_dir"
	zig_dir=$(find "$tmp_dir" -type d -name "zig-linux-${zig_arch}-${ZIG_VERSION}")
	mkdir -p "$HOME/.local/bin"
	cp "$zig_dir/zig" "$HOME/.local/bin/zig"
	chmod +x "$HOME/.local/bin/zig"
	rm -rf "$tmp_dir"
	if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
		echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
	fi
fi

# Download and install latest zls release for Linux (x86_64 and aarch64)
if ! command -v zls &>/dev/null; then
	ZLS_VERSION="0.14.0"
	arch=$(uname -m)
	case "$arch" in
		x86_64|amd64)
			zls_arch="x86_64"
			zls_asset="zls-x86_64-linux.tar.xz"
			;;
		aarch64|arm64)
			zls_arch="aarch64"
			zls_asset="zls-aarch64-linux.tar.xz"
			;;
		*)
			echo "Unsupported architecture for zls: $arch"; exit 1
			;;
	esac
	zls_url="https://github.com/zigtools/zls/releases/download/${ZLS_VERSION}/${zls_asset}"
	tmp_dir=$(mktemp -d)
	wget "$zls_url" -O "$tmp_dir/zls.tar.xz"
	tar -xf "$tmp_dir/zls.tar.xz" -C "$tmp_dir"
	zls_bin=$(find "$tmp_dir" -type f -name "zls")
	mkdir -p "$HOME/.local/bin"
	cp "$zls_bin" "$HOME/.local/bin/zls"
	chmod +x "$HOME/.local/bin/zls"
	rm -rf "$tmp_dir"
	if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
		echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
	fi
fi

# Download and install latest opencode release for this platform
if ! command -v opencode &>/dev/null; then
	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)
	case "$arch" in
		x86_64|amd64)
			arch=x64
			;;
		arm64|aarch64)
			arch=arm64
			;;
		*)
			echo "Unsupported architecture for opencode: $arch"; exit 1
			;;
	esac
	asset_name="opencode-${os}-${arch}.tar.gz"
	api_url="https://api.github.com/repos/scaryrawr/opencode/releases/latest"
	asset_url=$(curl -s $api_url | grep browser_download_url | grep "$asset_name" | cut -d '"' -f 4)
	if [ -z "$asset_url" ]; then
		echo "Could not find opencode release for $os $arch"; exit 1
	fi
	mkdir -p "$HOME/.local/bin"
	wget "$asset_url" -O /tmp/opencode.tar.gz
	tar -xzf /tmp/opencode.tar.gz -C /tmp
	chmod +x /tmp/opencode
	mv /tmp/opencode "$HOME/.local/bin/opencode"
	if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
		echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
	fi
fi
