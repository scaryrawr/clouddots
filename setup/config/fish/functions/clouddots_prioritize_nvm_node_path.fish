function clouddots_prioritize_nvm_node_path
    set -l nvm_node_bins
    set -l remaining_paths
    set -l nvm_dir "$HOME/.nvm"
    set -q NVM_DIR; and set nvm_dir "$NVM_DIR"
    set -l escaped_nvm_dir (string escape --style=regex "$nvm_dir")
    set -l nvm_dir_regex "^$escaped_nvm_dir/versions/node/[^/]+/bin\$"
    # Also match existing nvm PATH entries outside NVM_DIR, such as
    # devcontainer feature installs under /usr/local/share/nvm.
    set -l nvm_path_regex '/nvm/versions/node/[^/]+/bin$'

    for existing_path in $PATH
        set -l matches_configured_nvm_dir false
        set -l matches_nvm_install_path false

        string match -qr "$nvm_dir_regex" -- "$existing_path"; and set matches_configured_nvm_dir true
        string match -qr "$nvm_path_regex" -- "$existing_path"; and set matches_nvm_install_path true

        if test "$matches_configured_nvm_dir" = true; or test "$matches_nvm_install_path" = true
            set -a nvm_node_bins "$existing_path"
        else
            set -a remaining_paths "$existing_path"
        end
    end

    if test (count $nvm_node_bins) -gt 0
        set -gx PATH $nvm_node_bins $remaining_paths
    end
end
