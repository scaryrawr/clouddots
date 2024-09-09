#!/usr/bin/env bash

mkdir -p $HOME/.config/fish/conf.d

echo 'test -f /home/linuxbrew/.linuxbrew/bin/brew && /home/linuxbrew/.linuxbrew/bin/brew shellenv | source' > $HOME/.config/fish/conf.d/brew.fish

echo 'command -q fnm && fnm env --use-on-cd --shell fish | source' > $HOME/.config/fish/conf.d/fnm.fish

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' > $HOME/.config/fish/conf.d/cargo.fish

echo 'command -sq zoxide && zoxide init fish | source' > $HOME/.config/fish/conf.d/zoxide.fish

echo '
function dotnet
    if test -f /usr/local/bin/run-dotnet.sh
        /usr/local/bin/run-dotnet.sh $argv
    else
        command dotnet $argv
    end
end

function nuget
    if test -f /usr/local/bin/run-nuget.sh
        /usr/local/bin/run-nuget.sh $argv
    else
        command nuget $argv
    end
end

function npm
    if test -f /usr/local/bin/run-npm.sh
        /usr/local/bin/run-npm.sh $argv
    else
        command npm $argv
    end
end

function yarn
    if test -f /usr/local/bin/run-yarn.sh
        /usr/local/bin/run-yarn.sh $argv
    else
        command yarn $argv
    end
end

function npx
    if test -f /usr/local/bin/run-npx.sh
        /usr/local/bin/run-npx.sh $argv
    else
        command npx $argv
    end
end

function rush
    if test -f /usr/local/bin/run-rush.sh
        /usr/local/bin/run-rush.sh $argv
    else
        command rush $argv
    end
end

function rush-pnpm
    if test -f /usr/local/bin/run-rush-pnpm.sh
        /usr/local/bin/run-rush-pnpm.sh $argv
    else
        command rush-pnpm $argv
    end
end' > $HOME/.config/fish/conf.d/codespace.fish

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher scaryrawr/tide jorgebucaran/autopair.fish patrickf1/fzf.fish scaryrawr/fish-eza </dev/null"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
