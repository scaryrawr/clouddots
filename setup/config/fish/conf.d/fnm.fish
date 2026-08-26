set -l nvm_dir "$HOME/.nvm"
set -q NVM_DIR; and set nvm_dir "$NVM_DIR"

if status is-interactive && command -q fnm && not test -s "$nvm_dir/nvm.sh"
    fnm env --use-on-cd --shell fish | source
end
