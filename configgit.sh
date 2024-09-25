#!/usr/bin/env bash

# code works as the command even when using code-insiders.
CODE='code -w'
git config --global core.editor "$CODE"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "$CODE --merge \$REMOTE \$LOCAL \$BASE \$MERGED"
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "$CODE \$LOCAL \$REMOTE"
git config --global alias.co checkout
git config --global push.autoSetupRemote true
git config --global grep.lineNumber true
git config --global grep.column true

