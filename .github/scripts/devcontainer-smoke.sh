#!/usr/bin/env bash
set -euo pipefail

STRICT_MODE=true bash setup.sh

grep -Fxq "export BASH_ENV=\"\${BASH_ENV:-\$HOME/.bashenv}\"" "$HOME/.zshenv"
grep -Fxq "WORDCHARS=\${WORDCHARS/\\//}" "$HOME/.zshenv"
grep -Fxq 'antidote load' "$HOME/.zshrc"
zsh -lic '(( $+functions[antidote] ))'

grep -Fxq "set -q BASH_ENV; or set -gx BASH_ENV \"\$HOME/.bashenv\"" "$HOME/.config/fish/conf.d/bashenv.fish"
fish --command 'command -q fisher && command -q tide'
