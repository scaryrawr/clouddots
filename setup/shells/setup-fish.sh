#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.config/fish/conf.d"
mkdir -p "$HOME/.config/fish/functions"

path_entries=(
  "/home/linuxbrew/.linuxbrew/bin"
  "/home/linuxbrew/.linuxbrew/sbin"
  "$HOME/.local/bin"
  "$HOME/.npm-global/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.local/share/fnm"
  "$HOME/.bun/bin"
)

for path_entry in "${path_entries[@]}"; do
  [[ -d "$path_entry" ]] && fish --command="contains -- \"$path_entry\" \$fish_user_paths; or fish_add_path \"$path_entry\""
done

# Initialize fnm for fish only if fnm is installed
cat >"$HOME/.config/fish/conf.d/fnm.fish" <<EOF
status is-interactive && command -q fnm && fnm env --use-on-cd --shell fish | source
EOF

cat >"$HOME/.config/fish/conf.d/brew.fish" <<'EOF'
test -x /home/linuxbrew/.linuxbrew/bin/brew; and eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
EOF

cat >"$HOME/.config/fish/conf.d/browser.fish" <<'EOF'
test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY$DEVPOD" && set -gx BROWSER "$HOME/browser-opener.sh"
EOF

echo 'test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish' >"$HOME/.config/fish/conf.d/cargo.fish"

echo 'set -gx SHELL (which fish)' >"$HOME/.config/fish/conf.d/shell.fish"

echo 'set -q BASH_ENV; or set -gx BASH_ENV "$HOME/.bashenv"' >"$HOME/.config/fish/conf.d/bashenv.fish"

# Create gh-ado-codespaces notification configuration
# Named with 'a' prefix to load alphabetically before done.fish (d comes after a)
cat >"$HOME/.config/fish/conf.d/ado-codespaces.fish" <<'EOF'
# Configure gh-ado-codespaces notifications only in SSH+interactive sessions
if status is-interactive && test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY"
    # Configure done plugin to use gh-ado-codespaces notification service
    # Use set -g (global for session) not set -U (universal) so notifications
    # only work when connecting via gh-ado-codespaces/ssh
    if test -f "$HOME/notification-sender.sh"
        set -g __done_allow_nongraphical 1
        set -g __done_notification_command "$HOME/notification-sender.sh send \$title \$message"
        set -g __done_min_cmd_duration 5000
    end
end
EOF

fish --command="curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher jorgebucaran/replay.fish scaryrawr/copilot.fish scaryrawr/tide scaryrawr/codespace-nvm.fish scaryrawr/nvim.fish franciscolourenco/done </dev/null"
fish --command="tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Fade --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Many icons' --transient=Yes"
fish --command="command -q zoxide && fisher install scaryrawr/zoxide.fish </dev/null"
fish --command="command -q fzf && fisher install scaryrawr/fzf.fish scaryrawr/monorepo.fish </dev/null && set -Ux fzf_fd_opts --hidden && command -q delta && set -Ux fzf_diff_highlighter delta --paging=never"
fish --command="command -q eza && fisher install scaryrawr/fish-eza </dev/null"
fish --command="command -q tmux && fisher install scaryrawr/tmux.fish </dev/null && set -Ux TMUX_POWERLINE_BUBBLE_SEPARATORS true && set -Ux TMUX_SSHAUTO_START true"
fish --command="set -Ux EZA_STANDARD_OPTIONS --icons"
