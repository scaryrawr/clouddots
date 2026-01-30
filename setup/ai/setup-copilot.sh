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

# Ensure bun is available before using it
if ! command -v bun >/dev/null 2>&1; then
  # Try a common Bun installation path if bun is not currently in PATH
  if [[ -d "$HOME/.bun/bin" ]]; then
    PATH="$HOME/.bun/bin:$PATH"
  fi
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "Error: 'bun' is not installed or not in PATH. Please install Bun before running this script." >&2
  exit 1
fi

if command -v construct >/dev/null 2>&1; then
  echo "construct is already installed; skipping installation."
else
  bun add -g github:scaryrawr/construct
fi
