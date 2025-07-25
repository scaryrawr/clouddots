#!/usr/bin/env bash

SETTINGS_JSON="$HOME/.vscode-remote/data/Machine/settings.json"

# If settings.json does not exist, exit early (not an error)
if [ ! -f "$SETTINGS_JSON" ]; then
  exit 0
fi

jq '. + {
  "chat.tools.autoApprove": true,
  "chat.agent.maxRequests": 9001,
  "chat.editing.alwaysSaveWithGeneratedChanges": true,
  "github.copilot.chat.codesearch.enabled": true,
  "github.copilot.chat.editor.temporalContext.enabled": true,
  "github.copilot.chat.edits.temporalContext.enabled": true,
  "github.copilot.nextEditSuggestions.enabled": true,
  "github.copilot.chat.generateTests.codeLens": true,
  "github.copilot.chat.languageContext.typescript.enabled": true,
  "github.copilot.chat.search.semanticTextResults": true,
  "github.copilot.chat.completionContext.typescript.mode": "on",
  "github.copilot.chat.languageContext.fix.typescript.enabled": true,
  "github.copilot.chat.languageContext.inline.typescript.enabled": true,
  "github.copilot.nextEditSuggestions.fixes": true,
  "github.copilot.chat.agent.thinkingTool": true,
  "chat.edits2.enabled": true,
  "inlineChat.enableV2": true,
  "chat.agent.maxRequests": 9001,
}' "$SETTINGS_JSON" >tmp.json
mv tmp.json "$SETTINGS_JSON"

