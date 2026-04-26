#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.copilot"

config_file="$HOME/.copilot/config.json"
if [[ ! -f "$config_file" ]]; then
  cat >"$config_file" <<'EOF'
{
  "experimental": true,
  "mouse": true,
  "bash_env": true,
  "banner": "always"
}
EOF
fi

cat >"$HOME/.copilot/lsp-config.json" <<'EOF'
{
  "lspServers": {
    "typescript": {
      "command": "npx",
      "args": ["-y", "@typescript/native-preview", "--lsp", "--stdio"],
      "fileExtensions": {
        ".ts": "typescript",
        ".tsx": "typescriptreact",
        ".js": "javascript",
        ".jsx": "javascriptreact",
        ".mts": "typescript",
        ".cts": "typescript",
        ".mjs": "javascript",
        ".cjs": "javascript"
      }
    },
    "rust-analyzer": {
      "command": "rust-analyzer",
      "fileExtensions": {
        ".rs": "rust"
      }
    },
    "csharp": {
      "command": "dotnet",
      "args": [
        "tool",
        "run",
        "roslyn-language-server",
        "--stdio",
        "--autoLoadProjects"
      ],
      "fileExtensions": {
        ".cs": "csharp",
        ".csx": "csharp"
      }
    },
    "go": {
      "command": "gopls",
      "args": ["serve"],
      "fileExtensions": {
        ".go": "go"
      }
    },
    "zig": {
      "command": "zls",
      "fileExtensions": {
        ".zig": "zig",
        ".zon": "zig"
      }
    },
    "clangd": {
      "command": "clangd",
      "fileExtensions": {
        ".c": "c",
        ".h": "c",
        ".cpp": "cpp",
        ".hpp": "cpp",
        ".cc": "cpp",
        ".cxx": "cpp",
        ".hxx": "cpp",
        ".m": "objective-c",
        ".mm": "objective-cpp"
      }
    }
  }
}
EOF

marketplace_plugins=(
  "scaryrawr/scarypilot"
  "ast-grep/agent-skill"
)

install_plugins=(
  "chrome-devtools@scarypilot"
  "copilot@scarypilot"
  "ast-grep@ast-grep-marketplace"
)

# Only add azure-devops plugin if the repo origin is an Azure DevOps URL
origin_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$origin_url" == *"dev.azure.com/"* ]] || [[ "$origin_url" == *".visualstudio.com/"* ]] || [[ "$origin_url" == *"ssh.dev.azure.com:"* ]]; then
  install_plugins+=("azure-devops@scarypilot")
  install_plugins+=("workiq@copilot-plugins")
fi

for plugin in "${marketplace_plugins[@]}"; do
  copilot plugin marketplace add "$plugin" || true
done

for plugin in "${install_plugins[@]}"; do
  copilot plugin install "$plugin" || true
done
