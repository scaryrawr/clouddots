#!/usr/bin/env bash
set -e

# Get the directory where this script lives (for helper scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install helper scripts to ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/git-editor.sh" "$HOME/.local/bin/git-editor"
cp "$SCRIPT_DIR/git-difftool.sh" "$HOME/.local/bin/git-difftool"
cp "$SCRIPT_DIR/git-mergetool.sh" "$HOME/.local/bin/git-mergetool"
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

# Configure delta if available (provides rich CLI diff experience)
if command -v delta &>/dev/null; then
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global core.pager delta
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
cat >"$HOME/.config/lazygit/config.yml" <<'EOF'
git:
  paging:
    colorArg: always
    pager: delta --syntax-theme ansi --paging=never
os:
  # Use smart editor wrapper for lazygit too
  edit: '{{editor}} {{filename}}'
  editAtLine: '{{editor}} {{filename}}'
  editAtLineAndWait: 'git-editor {{filename}}'
  editInTerminal: true
EOF
