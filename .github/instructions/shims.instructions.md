---
applyTo: "setup/shims/*"
---

## Shim conventions

Shims are wrapper scripts in `setup/shims/` that get symlinked into `~/.local/bin/` by `setup/setup-shims.sh`. They intercept commands to add authentication or environment setup before calling the real binary.

### Common helper

All boilerplate (finding the real binary, rebuilding PATH, calling ado-auth-helper) lives in `setup/shims/_shim_helper.sh`. Individual shims only need to set `AUTH_ENV_VAR` and source the helper:

```bash
#!/usr/bin/env bash
AUTH_ENV_VAR="ARTIFACTS_ACCESSTOKEN"
source "$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)/_shim_helper.sh" "$@"
```

The `readlink -f` resolves the symlink so the helper is found relative to the real shim file in the repo, not the symlink in `~/.local/bin/`.

Files prefixed with `_` (like `_shim_helper.sh`) are skipped by `setup-shims.sh` and not symlinked.

### When creating or modifying shims:

1. **Shebang**: Always use `#!/usr/bin/env bash`
2. **Use the helper**: Set `AUTH_ENV_VAR` to the env var name for the auth token, then source `_shim_helper.sh` with `"$@"`
3. **No auth needed?**: Omit `AUTH_ENV_VAR` — the helper will just exec the real binary directly
4. **Custom logic**: If a shim needs behavior beyond what the helper provides, it can implement its own logic following the conventions below

### Helper internals (for reference or custom shims):

1. **Find the real binary**: Use `type -aP <command>` to locate the real binary, skipping the shim itself to avoid recursive calls
2. **Error handling**: Exit with an error if the real binary cannot be found
3. **Fallback behavior**: If the shim's enhancement (e.g., auth helper) is unavailable, fall back to calling the real binary directly with `exec`
4. **Pass all arguments**: Always forward `"$@"` to the real binary
5. **Prevent recursion**: Before calling the real binary, rebuild `PATH` by splitting on `:` and filtering out entries matching `$shim_dir` (and any empty entries) to avoid introducing `::` elements. This prevents other wrappers from finding our shim when they search PATH.
