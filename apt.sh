#!/usr/bin/env bash

packages=("fish" "zsh" "ripgrep")

if command -v apt &> /dev/null
then
	# Enable apt-add-respository
	sudo apt install software-properties-common -y

	# Add fish shell repository
	sudo apt-add-repository ppa:fish-shell/release-3 -y

	sudo apt update -y
	sudo apt upgrade -y

	# Install fish and other useful fun stuff
	sudo apt install ${packages[@]} -y
elif command -v dnf &> /dev/null
then
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

