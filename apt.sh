#!/usr/bin/env bash

export DEBIAN_FRONTEND="noninteractive"

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

declare -A package_map=(
	["fish"]="fish"
	["zsh"]="zsh"
	["rg"]="ripgrep"
	["fzf"]="fzf"
	["zoxide"]="zoxide"
	["file"]="file"
	["chafa"]="chafa"
	["bat"]="bat"
	["eza"]="eza"
	["fd"]="fd-find"
	["delta"]="git-delta"
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
	# If we're installing fzf, we want to install from source, as the debian version is out-of-date
	for i in "${!packages[@]}"; do
		if [[ "${packages[i]}" == "fzf" ]]; then
			packages[i]="golang-go"
		fi
		if [[ "${packages[i]}" == "eza" ]]; then
			sudo apt install cargo -y
			cargo install eza
			unset 'packages[i]'
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
