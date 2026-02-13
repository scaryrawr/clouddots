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
- **Config generation**: Configs like `.tmux.conf` are generated via heredocs (`cat > file <<EOF`), not copied from static files.
- **Execution order matters**: Scripts depend on tools installed by earlier stages (e.g., npm-tools.sh needs Node from fnm). Follow the established order in setup.sh.
- **Strict mode is opt-in**: Individual scripts use `set -e`, but setup.sh only enables it when `STRICT_MODE=true` or `CI=true`. Category runners propagate the flag by checking `[[ $- == *e* ]]`.
