if [ ! -z "$SSH_CONNECTION" ]
  for i in (cat /workspaces/.codespaces/shared/.env-secrets)
      set key (echo $i | sed "s/=.*//")
      set value (echo $i | sed "s/$key=//1")
      set decodedValue (echo $value | base64 -d | string collect)
      # Merge PATH - append entries from .env-secrets that aren't already present
      # so shell-managed paths (brew.fish, fnm.fish, etc.) keep priority.
      # Move Codespaces nvm node bins ahead of Homebrew so pre-installed nvm remains active.
      if test "$key" = PATH
          for p in (string split : $decodedValue)
              test -n "$p"; or continue
              set -l nvm_dir "$HOME/.nvm"
              set -q NVM_DIR; and set nvm_dir "$NVM_DIR"
              set -l escaped_nvm_dir (string escape --style=regex "$nvm_dir")
              if string match -qr "^$escaped_nvm_dir/versions/node/[^/]+/bin\$" -- "$p"; or string match -qr '/versions/node/[^/]+/bin$' -- "$p"
                  set remaining_paths
                  for existing_path in $PATH
                      test "$existing_path" != "$p"; and set -a remaining_paths "$existing_path"
                  end
                  set -gx PATH "$p" $remaining_paths
              else if not contains -- $p $PATH
                  set -gx PATH $PATH $p
              end
          end
          continue
      end
      set -gx $key $decodedValue
  end
end
