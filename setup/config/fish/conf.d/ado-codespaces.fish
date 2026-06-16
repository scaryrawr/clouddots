# Configure gh-ado-codespaces notifications only in SSH+interactive sessions
if status is-interactive && test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY"
    # Configure done plugin to use gh-ado-codespaces notification service
    # Use set -g (global for session) not set -U (universal) so notifications
    # only work when connecting via gh-ado-codespaces/ssh
    if test -f "$HOME/notification-sender.sh"
        set -g __done_allow_nongraphical 1
        set -g __done_notification_command "$HOME/notification-sender.sh send \$title \$message"
        set -g __done_min_cmd_duration 5000
    end
end
