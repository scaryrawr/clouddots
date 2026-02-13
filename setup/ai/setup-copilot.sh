#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.copilot"
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

copilot plugin marketplace add scaryrawr/scarypilot

copilot plugin install copilot@scarypilot
copilot plugin install azure-devops@scarypilot
