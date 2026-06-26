test -x /home/linuxbrew/.linuxbrew/bin/brew; and eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
# Re-prepend ~/.local/bin so shims override Homebrew binaries
test -d "$HOME/.local/bin"; and fish_add_path --move "$HOME/.local/bin"

# Keep any pre-existing nvm-managed node ahead of Homebrew
for nvm_node_bin in "$HOME"/.nvm/versions/node/*/bin
    test -d "$nvm_node_bin"; and contains -- "$nvm_node_bin" $PATH; or continue
    set remaining_paths
    for existing_path in $PATH
        test "$existing_path" != "$nvm_node_bin"; and set -a remaining_paths "$existing_path"
    end
    set -gx PATH "$nvm_node_bin" $remaining_paths
end
