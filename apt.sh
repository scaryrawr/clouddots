#!/usr/bin/env bash

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

declare -A package_map=(
	["fish"]="fish"
	["zsh"]="zsh"
	["rg"]="ripgrep"
	["fzf"]="fzf"
	["zoxide"]="zoxide"
	["sl"]="sl"
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
			sudo DEBIAN_FRONTEND="noninteractive" apt install cargo -y
			cargo install eza
			unset 'packages[i]'
		fi
	done

	# Enable apt-add-repository
	sudo DEBIAN_FRONTEND="noninteractive" apt install software-properties-common -y

	# Add fish shell repository
	if [[ " ${packages[*]} " =~ " fish " ]]; then
		sudo DEBIAN_FRONTEND="noninteractive" apt-add-repository ppa:fish-shell/release-3 -y
	fi

	# Add Go repository if golang-go is in the packages to install
	if [[ " ${packages[*]} " =~ " golang-go " ]]; then
		sudo DEBIAN_FRONTEND="noninteractive" add-apt-repository ppa:longsleep/golang-backports -y
	fi

	sudo DEBIAN_FRONTEND="noninteractive" apt update -y
	sudo DEBIAN_FRONTEND="noninteractive" apt upgrade -y

	# Install and upgrade packages
	if [ ${#packages[@]} -ne 0 ]; then
		sudo DEBIAN_FRONTEND="noninteractive" apt install "${packages[@]}" -y
	fi

	# Install fzf from source
	command -v go && go install github.com/junegunn/fzf@latest
elif command -v dnf &>/dev/null; then
	if [[ " ${packages[*]} " =~ " sl " ]]; then
		sudo dnf copr enable scaryrawr/sl -y
	fi

	if [ ${#packages[@]} -ne 0 ]; then
		sudo dnf update -y
		sudo dnf install --skip-unavailable "${packages[@]}" -y
	fi
else
	echo "Unknown package manager"
	exit 1
fi
