#!/usr/bin/env bash

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

packages=("fish" "zsh" "rg" "fzf" "zoxide")

# Remove packages that are already installed
for pkg in "${packages[@]}"; do
	if command -v "$pkg" &>/dev/null; then
		packages=("${packages[@]/$pkg}")
	fi
done

# Replace rg with package name ripgrep
for i in "${!packages[@]}"; do
	if [[ "${packages[i]}" == "rg" ]]; then
		packages[i]="ripgrep"
	fi
done

if command -v apt &>/dev/null; then
	# If we're installing fzf, we want to install from source, as the debian version is
	# out-of-date
	for i in "${!packages[@]}"; do
		if [[ "${packages[i]}" == "fzf" ]]; then
			packages[i]="golang-go"
		fi
	done

	# Enable apt-add-respository
	sudo DEBIAN_FRONTEND="noninteractive" apt install software-properties-common -y

	# Add fish shell repository
	if [[ " ${packages[@]} " =~ " fish " ]]; then
		sudo DEBIAN_FRONTEND="noninteractive" apt-add-repository ppa:fish-shell/release-3 -y
	fi

	# Add Go repository if golang-go is in the packages to install
	if [[ " ${packages[@]} " =~ " golang-go " ]]; then
		sudo DEBIAN_FRONTEND="noninteractive" add-apt-repository ppa:longsleep/golang-backports -y
	fi

	sudo DEBIAN_FRONTEND="noninteractive" apt update -y

	# Install fish and other useful fun stuff
	if [ ${#packages[@]} -ne 0 ]; then
		sudo DEBIAN_FRONTEND="noninteractive" apt install ${packages[@]} -y
		exit 0
	fi

	# Instal fzf from source
	command -v go && go install github.com/junegunn/fzf@latest
elif command -v dnf &>/dev/null; then
	if ! command -v eza &>/dev/null; then
		packages+=("eza")
	fi
	if [ ${#packages[@]} -ne 0 ]; then
		sudo dnf update -y
		sudo dnf install ${packages[@]} -y
	fi
else
	echo "Unknown package manager"
	exit 1
fi
