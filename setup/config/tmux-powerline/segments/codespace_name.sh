# shellcheck shell=bash
# Prints the Codespace name without the generated trailing suffix.
# CODESPACE_NAME is only injected by VS Code into its terminals, so SSH
# sessions (where tmux autostart triggers) won't have it.  Fall back to
# the Codespaces metadata file before resorting to hostname.

CODESPACE_ENV_JSON="/workspaces/.codespaces/shared/environment-variables.json"

run_segment() {
	local codespace_name
	local hostname_name

	codespace_name=${CODESPACE_NAME:-}

	# Env var missing - try the Codespaces metadata file
	if [ -z "$codespace_name" ] && [ -f "$CODESPACE_ENV_JSON" ]; then
		codespace_name=$(grep -o '"CODESPACE_NAME": *"[^"]*"' "$CODESPACE_ENV_JSON" 2>/dev/null | sed 's/.*: *"//;s/"$//')
	fi

	if [ -n "$codespace_name" ]; then
		echo "${codespace_name%-*}"
		return 0
	fi

	if command -v hostname >/dev/null 2>&1; then
		hostname_name=$(hostname)
		echo "${hostname_name%%.*}"
	fi
}
