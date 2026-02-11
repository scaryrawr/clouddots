---
applyTo: "setup/**/*.sh"
---

## Setup script conventions

When creating or modifying setup scripts, follow these rules:

1. **Shebang**: Always start with `#!/usr/bin/env bash`
2. **Strict mode**: Add `set -e` at the top of every individual script
3. **Idempotency**: Scripts must be safe to run multiple times. Check if tools/configs already exist before installing or writing:
   - Use `command -v <tool>` to check if a binary is installed
   - Use `[[ -f <path> ]]` or `[[ -d <path> ]]` to check for files/directories
   - Use `grep -qxF` before appending lines to config files
4. **Clone-or-pull pattern**: For git-based plugins, clone if the directory is missing, `git pull` if it already exists
5. **Config generation**: Generate config files via heredocs (`cat > file <<'EOF'`), not by copying static files
6. **Variables**: Use `lowercase_with_underscores` for variable names
7. **Paths**: Use `$HOME` not `~`, and always quote paths
8. **Install locations**: Binaries go to `~/.local/bin`, configs go to `~/.config/`
9. **Conditionals**: Use `[[ ]]` for tests, `command -v` for existence checks
10. **Arrays**: Use bash arrays with `"${array[@]}"` quoting
11. **Execution order**: Scripts depend on tools installed by earlier stages. Do not assume tools from later stages are available.
12. **New tools**: Add a new `setup-<name>.sh` file in the appropriate subdirectory (`editors/`, `terminal/`, `ai/`). The category runner will auto-discover it.
