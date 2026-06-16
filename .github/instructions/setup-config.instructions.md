---
applyTo: "setup/config/**"
---

## Setup config file conventions

Files under `setup/config/` are checked-in source configs that setup scripts copy into user locations.

1. Keep content ready to deploy verbatim; do not rely on shell interpolation during copy.
2. Preserve the destination-oriented grouping, e.g. `setup/config/fish/conf.d/*.fish` copies to `$HOME/.config/fish/conf.d/`.
3. When moving or renaming a config file, update the matching `setup/**/*.sh` installer in the same change.
4. Use repo-owned static files for clobbered configs. User-seeded defaults may live here too, but installers should copy them only when the destination is missing.
