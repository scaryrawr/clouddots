#!/usr/bin/env bash
set -euo pipefail

STRICT_MODE=true bash setup.sh

command -v node >/dev/null
command -v npm >/dev/null
[[ -d "$HOME/.local/share/zsh" ]]

# The expected config line must retain its variable references literally.
# shellcheck disable=SC2016
grep -Fxq '[[ -r "$HOME/.bashenv" ]] && source "$HOME/.bashenv"' "$HOME/.bashrc"
BASH_ENV="$HOME/.bashenv" bash -c '
  command -v node >/dev/null &&
    [[ "$(type -t cd)" == builtin ]]
'
zsh -c '
  command -v brew >/dev/null &&
    [[ -n "$HOMEBREW_PREFIX" ]] &&
    command -v node >/dev/null
'

grep -Fxq "zstyle ':antidote:bundle:*' defer-options '-m'" "$HOME/.zshrc"
grep -Fq 'scaryrawr/zsh-macos-keybindings branch:fish-like-editing' "$HOME/.zsh_plugins.txt"
TERM="${TERM:-xterm-256color}" zsh -lic '
  (( $+functions[antidote] )) &&
    [[ "$WORDCHARS" != */* ]] &&
    [[ "$(bindkey -M main "^[^?")" == *backward-kill-word ]] &&
    [[ "$(bindkey -M main "^[[1;3D")" == *backward-word ]]
'

grep -Fxq "set -q BASH_ENV; or set -gx BASH_ENV \"\$HOME/.bashenv\"" "$HOME/.config/fish/conf.d/bashenv.fish"
fish --command '
  command -q fisher &&
    command -q tide &&
    replay "true" &&
    not functions -q cd
'
