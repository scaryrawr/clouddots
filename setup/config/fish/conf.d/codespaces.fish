if [ ! -z "$SSH_CONNECTION" ]
  for i in (cat /workspaces/.codespaces/shared/.env-secrets)
      set key (echo $i | sed "s/=.*//")
      set value (echo $i | sed "s/$key=//1")
      set decodedValue (echo $value | base64 -d | string collect)
      # Merge PATH - append entries from .env-secrets that aren't already present
      # so shell-managed paths (brew.fish, fnm.fish, etc.) keep priority.
      if test "$key" = PATH
          for p in (string split : $decodedValue)
              test -n "$p"; and not contains -- $p $PATH; and set -gx PATH $PATH $p
          end
          continue
      end
      set -gx $key $decodedValue
  end
end
