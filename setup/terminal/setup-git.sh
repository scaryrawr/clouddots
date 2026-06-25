#!/usr/bin/env bash
set -e

# Get the directory where this script lives (for helper scripts)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/lazygit"

# Install helper scripts to ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp "$script_dir/git-editor.sh" "$HOME/.local/bin/git-editor"
cp "$script_dir/git-difftool.sh" "$HOME/.local/bin/git-difftool"
cp "$script_dir/git-mergetool.sh" "$HOME/.local/bin/git-mergetool"
chmod +x "$HOME/.local/bin/git-editor" "$HOME/.local/bin/git-difftool" "$HOME/.local/bin/git-mergetool"

# Core git aliases and settings
git config --global alias.co checkout
git config --global branch.sort -committerdate
git config --global column.ui auto
git config --global commit.verbose true
git config --global core.fsmonitor true
git config --global core.untrackedCache true
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global grep.column true
git config --global grep.lineNumber true
git config --global merge.conflictstyle zdiff3
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global rebase.updateRefs true
git config --global rerere.autoupdate true
git config --global rerere.enabled true
git config --global tag.sort version:refname

# Use smart wrapper scripts that detect VS Code vs native CLI at runtime
git config --global core.editor "$HOME/.local/bin/git-editor"
git config --global diff.tool smartdiff
git config --global difftool.smartdiff.cmd "$HOME/.local/bin/git-difftool \$LOCAL \$REMOTE"
git config --global merge.tool smartmerge
git config --global mergetool.smartmerge.cmd "$HOME/.local/bin/git-mergetool \$REMOTE \$LOCAL \$BASE \$MERGED"

# Use hunk as the git pager when available (interactive review on a TTY,
# transparent pass-through when piped). See https://github.com/modem-dev/hunk
if command -v hunk &>/dev/null; then
  git config --global core.pager "hunk pager"
fi

# Configure delta if available. Delta still powers the interactive add filter
# (git add -p), where hunk's full-screen TUI cannot act as a streaming filter.
if command -v delta &>/dev/null; then
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.line-numbers true
  git config --global delta.navigate true
  git config --global delta.side-by-side true
  git config --global delta.true-color always
  git config --global delta.syntax-theme ansi
  # Hyperlinks work in VS Code terminal and some other terminals
  git config --global delta.hyperlinks true
  git config --global delta.hyperlinks-file-link-format 'file://{path}:{line}'
fi

# Configure lazygit with delta pager
mkdir -p "$HOME/.config/lazygit"
cp -f "$config_dir/config.yml" "$HOME/.config/lazygit/config.yml"
