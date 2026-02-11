---
applyTo: "setup/shims/*"
---

## Shim conventions

Shims are wrapper scripts in `setup/shims/` that get symlinked into `~/.local/bin/` by `setup/setup-shims.sh`. They intercept commands to add authentication or environment setup before calling the real binary.

When creating or modifying shims:

1. **Shebang**: Always use `#!/usr/bin/env bash`
2. **Find the real binary**: Use `type -aP <command>` to locate the real binary, skipping the shim itself to avoid recursive calls
3. **Error handling**: Exit with an error if the real binary cannot be found
4. **Fallback behavior**: If the shim's enhancement (e.g., auth helper) is unavailable, fall back to calling the real binary directly with `exec`
5. **Pass all arguments**: Always forward `"$@"` to the real binary
6. **Prevent recursion**: Before calling the real binary, rebuild `PATH` by splitting on `:` and filtering out entries matching `$shim_dir` (and any empty entries) to avoid introducing `::` elements. This prevents other wrappers from finding our shim when they search PATH.
