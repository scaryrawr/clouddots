#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.tmux/plugins"
plugins=(
  "https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  "https://github.com/sainnhe/tmux-fzf $HOME/.tmux/plugins/tmux-fzf"
  "https://github.com/erikw/tmux-powerline $HOME/.tmux/plugins/tmux-powerline"
)

# Clone or pull each plugin
for plugin in "${plugins[@]}"; do
  repo_url=$(echo "$plugin" | awk '{print $1}')
  clone_dir=$(echo "$plugin" | awk '{print $2}')
  if [ -d "$clone_dir" ] && [ "$(ls -A $clone_dir)" ]; then
    (cd "$clone_dir" && git pull)
  else
    git clone "$repo_url" "$clone_dir"
  fi
done

"$HOME/.tmux/plugins/tmux-powerline/generate_config.sh"
if [[ ! -f "$HOME/.config/tmux-powerline/config.sh" && -f "$HOME/.config/tmux-powerline/config.sh.default" ]]; then
  mv "$HOME/.config/tmux-powerline/config.sh.default" "$HOME/.config/tmux-powerline/config.sh"
fi
if [[ -f "$HOME/.config/tmux-powerline/config.sh" ]]; then
  sed -i 's/export TMUX_POWERLINE_THEME="default"/export TMUX_POWERLINE_THEME="base16"/' "$HOME/.config/tmux-powerline/config.sh"
fi

# Create or overwrite tmux configuration
cat >"$HOME/.tmux.conf" <<EOF
set -g mouse on
set -g escape-time 10
set -g focus-events on
set -g bell-action any
set -g monitor-activity on
set -ga terminal-features ',*:RGB'
set -g default-terminal "tmux-256color"
set -g set-titles on
set -g set-titles-string '🐚 #W'
set -g allow-rename on
set -ga update-environment ' CODESPACE_NAME CODESPACE_VSCODE_FOLDER VSCODE_GIT_ASKPASS_NODE VSCODE_GIT_ASKPASS_EXTRA_ARGS VSCODE_GIT_ASKPASS_MAIN VSCODE_GIT_IPC_HANDLE VSCODE_IPC_HOOK_CLI VSCODE_INJECTION VSCODE_NONCE'
# Eagerly set CODESPACE_NAME in global env — update-environment only syncs on attach,
# which can miss vars if the server started before they were exported.
run-shell 'if [ -n "$CODESPACE_NAME" ]; then tmux set-environment -g CODESPACE_NAME "$CODESPACE_NAME"; fi'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'erikw/tmux-powerline'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.tmux/plugins/tpm/tpm'
EOF

mkdir -p "$HOME/.config/tmux-powerline/themes" "$HOME/.config/tmux-powerline/segments"

cat >"$HOME/.config/tmux-powerline/segments/codespace_name.sh" <<'EOF'
# shellcheck shell=bash
# Prints the Codespace name without the generated trailing suffix.

run_segment() {
	local codespace_name
	local hostname_name

	codespace_name=${CODESPACE_NAME:-}
	if [ -n "$codespace_name" ]; then
		echo "${codespace_name%-*}"
		return 0
	fi

	if command -v hostname >/dev/null 2>&1; then
		hostname_name=$(hostname)
		echo "${hostname_name%%.*}"
	fi
}
EOF

cat >"$HOME/.config/tmux-powerline/themes/base16.sh" <<'EOF'
# shellcheck shell=bash disable=SC2034
# Base16 Theme
# Uses the base16 color palette to inherit theme from terminal/shell.

if [ -n "$TMUX_POWERLINE_BUBBLE_SEPARATORS" ]; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
	TMUX_POWERLINE_SEPARATOR_THIN="|"
else
	if patched_font_in_use; then
		TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
		TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
		TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
		TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
	else
		TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
		TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
		TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
		TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
	fi
fi

# See Color formatting section below for details on what colors can be used here.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-black}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-white}
# shellcheck disable=SC2034
TMUX_POWERLINE_SEG_AIR_COLOR=$(air_color)

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}
TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN=${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN:-48}

# See `man tmux` for additional formatting options for the status line.
# The `format regular` and `format inverse` functions are provided as conveniences

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
	if [ -n "$TMUX_POWERLINE_BUBBLE_SEPARATORS" ]; then
		TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
			"#[$(format regular)]"
			"$TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR"
			"#[$(format inverse)]"
			" #I#F "
			"$TMUX_POWERLINE_SEPARATOR_THIN"
			" #W "
			"#[$(format regular)]"
			"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
		)
	else
		TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
			"#[$(format inverse)]"
			"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
			" #I#F "
			"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
			" #W "
			"#[$(format regular)]"
			"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
		)
	fi
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
		"$(format regular)"
	)
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
		"#[$(format regular)]"
		"  #I#{?window_flags,#F, } "
		"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
		" #W "
	)
fi

# Format: segment_name [background_color|default_bg_color] [foreground_color|default_fg_color] [non_default_separator|default_separator] [separator_background_color|no_sep_bg_color]
#                      [separator_foreground_color|no_sep_fg_color] [spacing_disable|no_spacing_disable] [separator_disable|no_separator_disable]
#
# * background_color and foreground_color. Color formatting (see `man tmux` for complete list):
#   * Named colors, e.g. black, red, green, yellow, blue, magenta, cyan, white
#   * Hexadecimal RGB string e.g. #ffffff
#   * 'default_fg_color|default_bg_color' for the default theme bg and fg color
#   * 'default' for the default tmux color.
#   * 'terminal' for the terminal's default background/foreground color
#   * The numbers 0-255 for the 256-color palette. Run `tmux-powerline/color-palette.sh` to see the colors.
# * non_default_separator - specify an alternative character for this segment's separator
#   * 'default_separator' for the theme default separator
# * separator_background_color - specify a unique background color for the separator
#   * 'no_sep_bg_color' for using the default coloring for the separator
# * separator_foreground_color - specify a unique foreground color for the separator
#   * 'no_sep_fg_color' for using the default coloring for the separator
# * spacing_disable - remove space on left, right or both sides of the segment:
#   * "no_spacing_disable" - don't disable spacing (default)
#   * "left_disable" - disable space on the left
#   * "right_disable" - disable space on the right
#   * "both_disable" - disable spaces on both sides
#   * - any other character/string produces no change to default behavior (eg "none", "X", etc.)
#
# * separator_disable - disables drawing a separator on this segment, very useful for segments
#   with dynamic background colours (eg tmux_mem_cpu_load):
#   * "no_separator_disable" - don't disable the separator (default)
#   * "separator_disable" - disables the separator
#   * - any other character/string produces no change to default behavior
#
# Example segment with separator disabled and right space character disabled:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} 0 0 right_disable separator_disable"
#
# Example segment with spacing characters disabled on both sides but not touching the default coloring:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} no_sep_bg_color no_sep_fg_color both_disable"
#
# Example segment with changing the foreground color of the default separator:
# "hostname 33 0 default_separator no_sep_bg_color 120"
#
## Note that although redundant the non_default_separator, separator_background_color and
# separator_foreground_color options must still be specified so that appropriate index
# of options to support the spacing_disable and separator_disable features can be used
# The default_* and no_* can be used to keep the default behaviour.

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"tmux_session_info blue black"
		"codespace_name magenta black"
		#"mode_indicator 165 0"
		#"ifstat 30 255"
		#"ifstat_sys 30 255"
		#"lan_ip brightblue black ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"
		#"vpn 24 255 ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"
		#"wan_ip brightblue black"
		"vcs_branch brightcyan black"
		#"vcs_compare 60 255"
		"vcs_staged brightred brightwhite"
		"vcs_modified red brightwhite"
		#"vcs_others 245 0"
	)
fi

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		# "earthquake 3 0"
		"pwd yellow black"
		#"macos_notification_count 29 255"
		#"mailcount 9 255"
		#"now_playing green black"
		#"cpu 240 136"
		#"load brightblack yellow"
		#"tmux_mem_cpu_load 234 136"
		#"battery blue black"
		#"air ${TMUX_POWERLINE_SEG_AIR_COLOR} 255"
		#"weather brightblue black"
		#"rainbarf 0 ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}"
		#"xkb_layout 125 117"
		"date_day cyan black"
		"date cyan black ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		#"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
	)
fi
EOF
