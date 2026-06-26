test -x /home/linuxbrew/.linuxbrew/bin/brew; and eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
# Re-prepend ~/.local/bin so shims override Homebrew binaries
test -d "$HOME/.local/bin"; and fish_add_path --move "$HOME/.local/bin"

# Keep any pre-existing nvm-managed node ahead of Homebrew
set -l nvm_node_bins
set -l remaining_paths
set -l nvm_dir "$HOME/.nvm"
set -q NVM_DIR; and set nvm_dir "$NVM_DIR"
set -l escaped_nvm_dir (string escape --style=regex "$nvm_dir")
for existing_path in $PATH
    if string match -qr "^$escaped_nvm_dir/versions/node/[^/]+/bin\$" -- "$existing_path"; or string match -qr '/versions/node/[^/]+/bin$' -- "$existing_path"
        set -a nvm_node_bins "$existing_path"
    else
        set -a remaining_paths "$existing_path"
    end
end

if test (count $nvm_node_bins) -gt 0
    set -l new_path
    for existing_path in $nvm_node_bins $remaining_paths
        test -n "$existing_path"; and set -a new_path "$existing_path"
    end
    set -gx PATH $new_path
end
