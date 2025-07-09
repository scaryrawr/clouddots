#!/usr/bin/env bash

# Enable yolo mode by default in dev containers
jq '. + {"chat.tools.autoApprove": true}' "$HOME/.vscode-remote/data/Machine/settings.json" > tmp.json 
mv tmp.json "$HOME/.vscode-remote/data/Machine/settings.json"