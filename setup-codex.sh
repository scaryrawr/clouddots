#!/usr/bin/env bash

mkdir -p $HOME/.codex/
cat >"$HOME/.codex/config.toml" <<'EOF'
oss_provider = "lmstudio"
model_provider = "lmstudio"
model = "qwen/qwen3-coder-30b"
model_reasoning_effort = "none"

[features]
skills = true
EOF
