#!/usr/bin/env bash

# Enable yolo mode by default in dev containers
jq '. + {"chat.tools.autoApprove": true}' "$HOME/.vscode-remote/data/Machine/settings.json" >tmp.json
mv tmp.json "$HOME/.vscode-remote/data/Machine/settings.json"

# Power level over 9000
jq '. + {"chat.agent.maxRequests": 9001}' "$HOME/.vscode-remote/data/Machine/settings.json" >tmp.json
mv tmp.json "$HOME/.vscode-remote/data/Machine/settings.json"
