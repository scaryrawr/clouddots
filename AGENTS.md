# AGENTS.md - Development Guidelines

## Build/Test Commands
- **Main setup**: `./setup.sh` (orchestrates all setup scripts)
- **Test binaries**: `.github/test-binaries.sh` (validates installed tools)
- **Single test**: Test individual tools with `<tool> --version` (fzf, eza, zoxide, delta)
- **⚠️ IMPORTANT**: Never run setup scripts locally - always test inside devcontainers only

## Code Style Guidelines
- **Shell scripting**: Use `#!/usr/bin/env bash` shebang, `set -e` for error handling
- **Variable naming**: Use lowercase with underscores (e.g., `prepend_entries`, `failed_tests`)
- **Arrays**: Use bash arrays with proper quoting: `"${array[@]}"`
- **Conditionals**: Use `[[ ]]` for bash conditionals, `command -v` for command existence checks
- **Error handling**: Exit with non-zero status on failure, use descriptive error messages
- **Path handling**: Use `$HOME` instead of `~`, quote paths with spaces
- **Comments**: Use `#` for comments, document complex logic and script purposes

## Project Structure
- Scripts are organized by function (system-deps.sh, setup-*.sh)
- Binary releases installed to `~/.local/bin`
- Configuration files go to appropriate XDG directories (`~/.config/`)
- All scripts should be executable and self-contained

## Best Practices
- **Testing Environment**: Only run and test scripts inside devcontainers - never locally
- Check if configuration already exists before adding duplicates
- Use conditional installation (check if tool exists first)
- Maintain idempotency - scripts should be safe to run multiple times
- Follow the established execution order in setup.sh