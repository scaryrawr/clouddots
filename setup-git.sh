#!/usr/bin/env bash

# code works as the command even when using code-insiders.
CODE='code -w'
git config --global alias.co checkout
git config --global branch.sort -committerdate
git config --global column.ui auto
git config --global commit.verbose true
git config --global core.editor "$CODE"
git config --global core.fsmonitor true
git config --global core.untrackedCache true
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "$CODE -d \$LOCAL \$REMOTE"
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global grep.column true
git config --global grep.lineNumber true
git config --global merge.conflictstyle zdiff3
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "$CODE --merge \$REMOTE \$LOCAL \$BASE \$MERGED"
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global rebase.updateRefs true
git config --global rerere.autoupdate true
git config --global rerere.enabled true
git config --global tag.sort version:refname
if command -v delta &> /dev/null; then
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global core.pager delta
  git config --global delta.hyperlinks-file-link-format 'vscode-insiders://file/{path}:{line}'
  git config --global delta.line-numbers true
  git config --global delta.navigate true
  git config --global delta.side-by-side true
  git config --global delta.true-color always
fi
