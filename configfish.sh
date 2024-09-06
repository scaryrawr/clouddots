#!/usr/bin/env bash

mkdir -p $HOME/.config/fish/conf.d

echo 'test -f /home/linuxbrew/.linuxbrew/bin/brew && /home/linuxbrew/.linuxbrew/bin/brew shellenv | source' > $HOME/.config/fish/conf.d/brew.fish

echo 'command -q fnm && fnm env --use-on-cd --shell fish | source' > $HOME/.config/fish/conf.d/fnm.fish

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' > $HOME/.config/fish/conf.d/cargo.fish

echo 'command -sq zoxide && zoxide init fish | source' > $HOME/.config/fish/conf.d/zoxide.fish

echo 'test -f /usr/local/bin/run-dotnet.sh && alias dotnet=/usr/local/bin/run-dotnet.sh
test -f /usr/local/bin/run-nuget.sh && alias nuget=/usr/local/bin/run-nuget.sh
test -f /usr/local/bin/run-npm.sh && alias npm=/usr/local/bin/run-npm.sh
test -f /usr/local/bin/run-yarn.sh && alias yarn=/usr/local/bin/run-yarn.sh
test -f /usr/local/bin/run-npx.sh && alias npx=/usr/local/bin/run-npx.sh
test -f /usr/local/bin/run-rush.sh && alias rush=/usr/local/bin/run-rush.sh
test -f /usr/local/bin/run-rush-pnpm.sh && alias rush-pnpm=/usr/local/bin/run-rush-pnpm.sh' > $HOME/.config/fish/conf.d/codespace.fish

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher ilancosman/tide@v6 jethrokuan/z jorgebucaran/autopair.fish patrickf1/fzf.fish scaryrawr/fish-eza </dev/null"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
