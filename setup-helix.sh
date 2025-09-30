#!/usr/bin/env bash
cat >"$HOME/.config/helix/config.toml" <<EOF
theme = "base16_default"

[editor]
line-number = "relative"

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"
EOF
