#!/usr/bin/env bash

packages=("fish" "zsh" "ripgrep" "fzf" "zoxide")

if command -v apt &> /dev/null
then
	# Enable apt-add-respository
	sudo DEBIAN_FRONTEND="noninteractive" apt install software-properties-common -y

	# Add fish shell repository
	sudo DEBIAN_FRONTEND="noninteractive" apt-add-repository ppa:fish-shell/release-3 -y

	sudo DEBIAN_FRONTEND="noninteractive" apt update -y

	# Install fish and other useful fun stuff
	sudo DEBIAN_FRONTEND="noninteractive" apt install ${packages[@]} -y
elif command -v dnf &> /dev/null
then
	packages+=("eza")
	sudo dnf update -y
	sudo dnf upgrade -y
	sudo dnf install ${packages[@]} -y
elif  command -v brew &> /dev/null
then
	brew update
	brew upgrade
	brew install ${packages[@]}
else
	echo "No package manager found"
	exit 1
fi

