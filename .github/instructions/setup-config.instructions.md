---
applyTo: "setup/config/**"
---

## Setup config file conventions

Files under `setup/config/` are checked-in source configs that setup scripts copy into user locations. They replace the old pattern of generating configs inline with `cat <<EOF` heredocs.

### Layout

1. Group by destination so the source tree mirrors where files land:
   - `setup/config/herdr/config.toml` → `$HOME/.config/herdr/config.toml`
   - `setup/config/fish/conf.d/*.fish` → `$HOME/.config/fish/conf.d/`
   - `setup/config/bat/config` → `$HOME/.config/bat/config`
   - `setup/config/lazygit/config.yml` → `$HOME/.config/lazygit/config.yml`
   - `setup/config/copilot/*` → `$HOME/.copilot/`
   - `setup/config/playwright/cli.config.json` → `$HOME/.playwright/cli.config.json`
2. Keep content ready to deploy verbatim. Do not rely on shell interpolation during copy — what is in the file is exactly what gets installed.

### How installers consume these files

Installers live in `setup/**/*.sh` and resolve the config directory relative to themselves, then copy:

```bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$script_dir/../config/<tool>"

mkdir -p "$HOME/.config/<tool>"
cp -f "$config_dir/config" "$HOME/.config/<tool>/config"   # repo-owned: clobber
```

1. **Repo-owned configs** (the repo is the source of truth): copy with `cp -f` so each run refreshes the destination. This is idempotent by overwriting.
2. **User-seeded defaults** (files users are expected to edit afterward): copy only when the destination is missing, e.g. `[[ -f "$dest" ]] || cp "$src" "$dest"`. See `setup/ai/setup-pi.sh` (`AGENTS.md`).
3. **Globbed copies** are fine when a whole directory is repo-owned, e.g. `cp -f "$config_dir"/*.fish "$HOME/.config/fish/conf.d/"`.
4. Always `mkdir -p` the destination directory before copying.

### When changing configs

1. Edit the static file under `setup/config/` directly — do not reintroduce heredocs in the installer for repo-owned content.
2. When moving or renaming a config file, update the matching `setup/**/*.sh` installer (its `cp` source/destination) in the same change.
3. Reserve heredocs in installers for genuinely dynamic/generated values (e.g. values that depend on runtime environment), not for static content that could be a checked-in file.
