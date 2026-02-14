#!/usr/bin/env bash
set -e

SETTINGS_JSON="$HOME/.vscode-remote/data/Machine/settings.json"

# If settings.json does not exist, exit early (not an error)
if [ ! -f "$SETTINGS_JSON" ]; then
  exit 0
fi

jq '. + {
  "chat.agent.maxRequests": 9001,
  "chat.edits2.enabled": true,
  "chat.math.enabled": true,
  "chat.mcp.autoStart": "newAndOutdated",
  "chat.tools.terminal.enableAutoApprove": true,
  "chat.useClaudeSkills": true,
  "chat.useNestedAgentsMdFiles": true,
  "github.copilot.chat.agent.autoFix": true,
  "github.copilot.chat.agent.thinkingTool": true,
  "github.copilot.chat.codesearch.enabled": true,
  "github.copilot.chat.editor.temporalContext.enabled": true,
  "github.copilot.chat.generateTests.codeLens": true,
  "inlineChat.enableV2": true,
  "inlineChat.lineEmptyHint": true,
  "inlineChat.lineNaturalLanguageHint": true,
  "search.searchView.semanticSearchBehavior": "always"
}' "$SETTINGS_JSON" >tmp.json
mv tmp.json "$SETTINGS_JSON"

