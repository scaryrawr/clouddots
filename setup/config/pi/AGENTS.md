# Coding Preferences

Write code that is easy for future consumers to understand and change.

- Document functions, types, interfaces, classes, modules, and other reusable APIs with concise comments that explain their purpose, inputs, outputs, errors, and important constraints. Do not over-document obvious implementation details.
- Add brief comments for complex internal logic only when they clarify intent, tradeoffs, or non-obvious behavior.
- Follow SOLID design principles where they improve maintainability, especially single responsibility, explicit dependencies, and dependency inversion. Keep designs simple and avoid abstractions that are not yet justified.
- Use test-driven development when practical: describe or add a failing test first, implement the smallest useful change, then refactor while keeping tests green.
- Prefer dependency injection and small interfaces or protocols at boundaries so behavior can be tested without relying on concrete infrastructure.
- Consider established design patterns when they fit the problem, but do not force a pattern where straightforward code is clearer.
- Prefer modern language and library features when they improve correctness, clarity, performance, or maintainability. Reconsider older default approaches when newer standard capabilities provide a better fit.
- Treat your built-in knowledge of APIs, library versions, and idioms as potentially out-of-date. It is fine for an initial implementation, but verify current APIs, defaults, and recommended practices against authoritative sources (official docs, the installed version's types/signatures) before finalizing.

# CLI Tooling

Use installed command-line tools to investigate, edit, and validate efficiently, but verify optional tools with `command -v <tool>` before relying on them. Prefer non-interactive commands, structured output such as `--json` with `jq`, and repo-provided scripts, lockfiles, and toolchain files over global defaults.

- Prefer `gh` for GitHub issues, pull requests, releases, workflow runs, and repository metadata; check `gh auth status` before authenticated operations and avoid exposing tokens or private data.
- Prefer `git` for local status, diffs, branches, and commits; avoid destructive history or working-tree operations unless explicitly requested.
- Prefer `rg`, `fd`, `jq`, and syntax-aware tools like `ast-grep` when available for fast discovery and safer rewrites.
- Use language and package tools that match the repository configuration, such as Node/pnpm/bun, Python/uv/ruff/pyright, Go, Rust, .NET, or similar.
- Do not install new tools, start services, change cloud resources, run costly operations, or use interactive TUIs unless the user asks or approves.
