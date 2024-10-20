#!/usr/bin/env bash

mkdir -p $HOME/.config/fish/conf.d
mkdir -p $HOME/.config/fish/functions

echo 'test -f /home/linuxbrew/.linuxbrew/bin/brew && /home/linuxbrew/.linuxbrew/bin/brew shellenv | source' > $HOME/.config/fish/conf.d/brew.fish

echo 'command -q fnm && fnm env --use-on-cd --shell fish | source' > $HOME/.config/fish/conf.d/fnm.fish

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' > $HOME/.config/fish/conf.d/cargo.fish

echo 'command -sq zoxide && zoxide init fish | source' > $HOME/.config/fish/conf.d/zoxide.fish

echo 'function dotnet
    if test -f /usr/local/bin/run-dotnet.sh
        /usr/local/bin/run-dotnet.sh $argv
    else
        command dotnet $argv
    end
end' > $HOME/.config/fish/functions/dotnet.fish

echo 'function nuget
    if test -f /usr/local/bin/run-nuget.sh
        /usr/local/bin/run-nuget.sh $argv
    else
        command nuget $argv
    end
end' > $HOME/.config/fish/functions/nuget.fish

echo 'function npm
    if test -f /usr/local/bin/run-npm.sh
        /usr/local/bin/run-npm.sh $argv
    else
        command npm $argv
    end
end' > $HOME/.config/fish/functions/npm.fish

echo 'function yarn
    if test -f /usr/local/bin/run-yarn.sh
        /usr/local/bin/run-yarn.sh $argv
    else
        command yarn $argv
    end
end' > $HOME/.config/fish/functions/yarn.fish

echo 'function npx
    if test -f /usr/local/bin/run-npx.sh
        /usr/local/bin/run-npx.sh $argv
    else
        command npx $argv
    end
end' > $HOME/.config/fish/functions/npx.fish

echo 'function rush
    if test -f /usr/local/bin/run-rush.sh
        /usr/local/bin/run-rush.sh $argv
    else
        command rush $argv
    end
end' > $HOME/.config/fish/functions/rush.fish

echo 'function rush-pnpm
    if test -f /usr/local/bin/run-rush-pnpm.sh
        /usr/local/bin/run-rush-pnpm.sh $argv
    else
        command rush-pnpm $argv
    end
end' > $HOME/.config/fish/functions/rush-pnpm.fish

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher scaryrawr/tide jorgebucaran/autopair.fish </dev/null"
fish --command="tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Fade --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Many icons' --transient=Yes"
fish --command="command -q fzf && fisher install patrickf1/fzf.fish </dev/null"
fish --command="command -q eza && fisher install scaryrawr/fish-eza </dev/null"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
fish --command="fish_add_path ~/.deno/bin"
