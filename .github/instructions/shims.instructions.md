---
applyTo: "setup/shims/*"
---

## Shim conventions

Shims are compatibility wrappers in `setup/shims/` that get symlinked into `~/.local/bin/` by `setup/setup-shims.sh`. The repo currently owns only the `chafa` wrapper.

Do not add repo-managed ADO or package-manager authentication shims for `az`, `bun`, `bunx`, `npm`, `npx`, `yarn`, `pnpm`, or `pnpx`. Codespaces handles supported tools through the `artifacts-helper` devcontainer feature, and duplicate wrappers can create command-resolution loops.

### When creating or modifying shims:

1. **Shebang**: Always use `#!/usr/bin/env bash`
2. **Strict mode**: Use `set -e`
3. **Find the real binary**: Use `type -aP <command>` and skip the shim itself to avoid recursion
4. **Error handling**: Exit with an error when the real binary cannot be found
5. **Pass all arguments**: Always forward `"$@"` to the real binary
