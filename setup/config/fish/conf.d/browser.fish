test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY$DEVPOD" && set -gx BROWSER "$HOME/browser-opener.sh"
