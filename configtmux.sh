#!/usr/bin/env bash

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

mkdir -p "$HOME/.tmux/plugins"
plugins=(
  "https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
  "https://github.com/erikw/tmux-powerline $HOME/.tmux/plugins/tmux-powerline"
)

# Clone or pull each plugin
for plugin in "${plugins[@]}"; do
	repo_url=$(echo "$plugin" | awk '{print $1}')
	clone_dir=$(echo "$plugin" | awk '{print $2}')
	if [ -d "$clone_dir" ] && [ "$(ls -A $clone_dir)" ]; then
		pushd "$clone_dir" && git pull
		popd
	else
		git clone "$repo_url" "$clone_dir"
	fi
done

"$HOME/.tmux/plugins/tmux-powerline/generate_config.sh"
mv "$HOME/.config/tmux-powerline/config.sh.default" "$HOME/.config/tmux-powerline/config.sh"
sed -i 's/export TMUX_POWERLINE_THEME="default"/export TMUX_POWERLINE_THEME="base16"/' "$HOME/.config/tmux-powerline/config.sh"

# Create or overwrite tmux configuration
cat > "$HOME/.tmux.conf" << EOF
set -g mouse on
set -g escape-time 10
set -g focus-events on
set -ga terminal-features ',*:RGB'
set -g default-terminal "tmux-256color"
set -ga update-environment ' CODESPACE_VSCODE_FOLDER VSCODE_GIT_ASKPASS_NODE VSCODE_GIT_ASKPASS_EXTRA_ARGS VSCODE_GIT_ASKPASS_MAIN VSCODE_GIT_IPC_HANDLE VSCODE_IPC_HOOK_CLI VSCODE_INJECTION VSCODE_NONCE'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'erikw/tmux-powerline'

run '~/.tmux/plugins/tpm/tpm'
EOF

mkdir -p "$HOME/.config/tmux-powerline/themes"

cat > "$HOME/.config/tmux-powerline/themes/base16.sh" << 'EOF'
# shellcheck shell=bash disable=SC2034
####################################################################################################
# modified to use color names and less bubbly by @scaryrawr
# This is a bubble theme created by @embe221ed (https://github.com/embe221ed)
# colors are inspired by catppuccin palettes (https://github.com/catppuccin/catppuccin)
####################################################################################################
base="terminal"
mantle="terminal"
crust="black"
eggplant="magenta"
sky_blue="brightcyan"
spotify_green="green"
spotify_black="black"

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

# See Color formatting section below for details on what colors can be used here.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-black}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-white}
TMUX_POWERLINE_SEG_AIR_COLOR=$(air_color)

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

# See `man tmux` for additional formatting options for the status line.
# The `format regular` and `format inverse` functions are provided as conveinences

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
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
		"$TMUX_POWERLINE_SEPARATOR_THIN"
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
#
# * separator_disable - disables drawing a separator on this segment, very useful for segments
#   with dynamic background colours (eg tmux_mem_cpu_load):
#   * "no_separator_disable" - don't disable the separator (default)
#   * "separator_disable" - disables the separator
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
# of options to support the spacing_disable and separator_disable features can be used.
# The default_* and no_* can be used to keep the default behaviour.

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"tmux_session_info blue black"
		"hostname magenta black"
		#"ifstat 30 255"
		#"ifstat_sys 30 255"
		#"lan_ip $sky_blue black" #${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"
		#"wan_ip $sky_blue black"
		"vcs_branch brightblack"
		#"air ${TMUX_POWERLINE_SEG_AIR_COLOR} black"
		# "vcs_compare red 255"
		"vcs_staged brightred brightwhite"
		"vcs_modified red brightwhite"
		# "vcs_others 245 0"
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
		#"load 237 167"
		#"tmux_mem_cpu_load 234 136"
		#"battery blue black"
		#"weather brightblue black"
		#"rainbarf 0 ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}"
		#"xkb_layout 125 117"
		"date_day cyan black"
		"date cyan black ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		"time cyan black ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		#"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
	)
fi

EOF
