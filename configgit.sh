#!/usr/bin/env bash

CODE=$(type code-insiders &>/dev/null && echo 'code-insiders -w' || echo 'code -w')
git config --global core.editor "$CODE"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "$CODE \$MERGED"
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "$CODE \$LOCAL \$REMOTE"
