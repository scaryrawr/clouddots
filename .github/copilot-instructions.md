# Copilot Instructions

## Architecture

Cloud Dots is a dotfiles repo for GitHub Codespaces and VS Code Devcontainers. The entry point is `setup.sh`, which orchestrates all other scripts in a fixed order:

1. `setup/core/system-deps.sh` — apt/dnf packages, Bun
2. `setup/core/homebrew.sh` — Homebrew + CLI tools
3. fnm + Node.js (inline in setup.sh)
4. `setup/core/npm-tools.sh` — global npm packages
5. Shell configs (bash → zsh → fish)
6. `setup/setup-editors.sh` → runs all `setup/editors/setup-*.sh`
7. `setup/setup-terminal.sh` → runs all `setup/terminal/setup-*.sh`
8. `setup/setup-ai.sh` → runs all `setup/ai/setup-*.sh`
9. `setup/setup-shims.sh` → symlinks `setup/shims/*` to `~/.local/bin/`

Category runners (`setup-editors.sh`, `setup-terminal.sh`, `setup-ai.sh`) auto-discover and run all `setup-*.sh` files in their subdirectory via glob. New tools are added by creating a `setup-<name>.sh` file in the appropriate subdirectory.

Shims in `setup/shims/` are wrapper scripts that get symlinked into `~/.local/bin/`. They intercept commands (e.g., `az`, `bun`, `npm`) to add authentication or environment setup before calling the real binary.

Repo-owned configuration is kept as static files in `setup/config/`, organized to mirror each tool's destination path. Installer scripts copy these into place (clobbering with `cp -f`) rather than generating them with heredocs. This makes config content reviewable, diffable, and editable directly instead of buried inside shell strings.

## Testing

**Only run and test scripts inside devcontainers — never locally.** Open the repo in a devcontainer (`.devcontainer/devcontainer.json`) and run `bash setup.sh`. There is no test suite; validation is manual.

Set `STRICT_MODE=true` or `CI=true` to enable `set -e` in the top-level orchestrator.

## Code Style

- Shebang: `#!/usr/bin/env bash`
- Use `set -e` for error handling in individual scripts
- Variable names: `lowercase_with_underscores`
- Arrays: bash arrays with `"${array[@]}"` quoting
- Conditionals: `[[ ]]` for tests, `command -v` for existence checks
- Paths: `$HOME` not `~`, always quote paths
- Binaries install to `~/.local/bin`, configs to `~/.config/`

## Repository Structure

- `setup.sh` — Main orchestrator entry point
- `setup/core/` — Bootstrap: system packages, Homebrew, npm tools
- `setup/config/` — Checked-in static config files, grouped by destination (`tmux/`, `fish/conf.d/`, `copilot/`, `bat/`, `lazygit/`, `playwright/`, `tmux-powerline/`), copied into place by installers
- `setup/shells/` — Shell configs (bash, zsh, fish)
- `setup/editors/` — Editor setup (Neovim, Helix, VS Code)
- `setup/terminal/` — Terminal tools (tmux, git, bat)
- `setup/ai/` — AI tooling (Copilot)
- `setup/shims/` — Command wrapper scripts symlinked to `~/.local/bin/`
- `setup/setup-*.sh` — Category runners that auto-discover scripts in subdirectories
- `.devcontainer/` — Devcontainer definitions for testing

## Validation

- Lint shell scripts with `shellcheck`: `shellcheck setup/**/*.sh setup.sh`
- There is no automated test suite. Validate by running `bash setup.sh` inside a devcontainer.

## Key Conventions

- **Idempotency**: Every script must be safe to run multiple times. Check if tools/configs exist before installing or writing. Use `grep -qxF` before appending lines to config files.
- **Clone-or-pull pattern**: Git-based plugins use a consistent pattern — clone if missing, `git pull` if present.
- **Static config files**: Repo-owned config content lives as checked-in static files under `setup/config/`, mirroring the destination layout (e.g. `setup/config/tmux/tmux.conf` → `~/.tmux.conf`, `setup/config/fish/conf.d/*.fish` → `~/.config/fish/conf.d/`). Installers resolve them via `config_dir="$script_dir/../config/<tool>"` and copy with `cp -f` for clobbered configs. Reserve heredocs for dynamic/generated values only. For user-seeded defaults (files users are expected to edit), copy only when the destination is missing.
- **Execution order matters**: Scripts depend on tools installed by earlier stages (e.g., npm-tools.sh needs Node from fnm). Follow the established order in setup.sh.
- **Strict mode is opt-in**: Individual scripts use `set -e`, but setup.sh only enables it when `STRICT_MODE=true` or `CI=true`. Category runners propagate the flag by checking `[[ $- == *e* ]]`.
- **Never let Homebrew install `node`**: Codespaces ships its own global node install, and `brew remove node` fails when a brew formula depends on it. Do NOT add Homebrew formulae that depend on `node` (e.g. `prettier`, `yaml-language-server`, `markdownlint-cli2`) to `homebrew.sh` — install node-based tools via `npm install -g` in `setup/core/npm-tools.sh` instead. Before adding any formula to `homebrew.sh`, verify it doesn't pull in node (check `dependencies` at `formulae.brew.sh/api/formula/<name>.json`, or `brew deps <name>`).
- **LazyVim toolchains are pre-installed, not Mason-managed**: Our Neovim config (`scaryrawr/lazyvim`, cloned by `setup/editors/setup-neovim.sh`) enables many language extras that normally rely on Mason to fetch LSP servers/toolchains on demand. Mason fails on some Codespaces, so the corresponding toolchains and servers are pre-installed via `setup/core/homebrew.sh` (or npm-tools.sh / uv). When enabling a new language extra in the lazyvim config, add its toolchain + LSP server to `homebrew.sh` so it works out-of-the-box — unless the server is node-based, in which case add it to `npm-tools.sh` (see the node rule above).
- **AI capabilities: plugins vs. skills (two distinct sources)**: `setup/ai/setup-copilot.sh` installs agent-specific *plugins* from `scaryrawr/scarypilot`. `setup/ai/setup-skills.sh` installs cross-agent *skills* from `scaryrawr/agentic` via `gh skill install ... --scope user --agent <agent>` for every agent in its `AGENTS` array. Add new portable AI capabilities as agentic skills in `setup-skills.sh`, not as plugins. Azure DevOps tooling (`ado-cli`, `ado-pr`, `ado-work-items`, `ado-make-pr`, `ado-review-pr`) lives as agentic skills gated on an Azure DevOps `git remote get-url origin` (`dev.azure.com/`, `.visualstudio.com/`, `ssh.dev.azure.com:`); it is not the former `azure-devops@scarypilot` plugin.
- **Diff tooling (hunk + delta coexist deliberately)**: hunk is git's `core.pager` and the native `git-difftool` choice (interactive review TUI). delta is kept on purpose for streaming/non-TTY consumers where hunk only echoes raw diff: git `interactive.diffFilter` (`git add -p`), lazygit's inline pager, and fish's `fzf_diff_highlighter`. Do not remove delta to "consolidate" on hunk. See `setup/terminal/setup-git.sh`, `setup/terminal/git-difftool.sh`, `setup/config/lazygit/config.yml`.
