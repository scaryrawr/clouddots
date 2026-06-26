test -x /home/linuxbrew/.linuxbrew/bin/brew; and eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
# Re-prepend ~/.local/bin so shims override Homebrew binaries
test -d "$HOME/.local/bin"; and fish_add_path --move "$HOME/.local/bin"

# Keep any pre-existing nvm-managed node ahead of Homebrew
clouddots_prioritize_nvm_node_path
