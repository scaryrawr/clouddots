function clouddots_prioritize_nvm_node_path
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
        set -gx PATH $nvm_node_bins $remaining_paths
    end
end
