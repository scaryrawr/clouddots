# Cloud Dots

These are dotfiles for use with [GitHub CodeSpaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) or [Visual Studio Code Containers](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories).

## Script Organization (2025)

Scripts are now organized by function for clarity and maintainability:

- **setup.sh**: Main orchestrator. Runs all other scripts in the correct order.
- **system-deps.sh**: Installs system-level dependencies (apt/dnf/cargo/go/opencode).
- **npm-tools.sh**: Installs global npm tools (language servers, etc).
- **setup-bash.sh**: Configures bash environment and PATH.
- **setup-zsh.sh**: Configures zsh, oh-my-zsh plugins, powerlevel10k, etc.
- **setup-fish.sh**: Configures fish, Fisher plugins, fnm, zoxide, fzf, eza, tmux, etc.
- **setup-tmux.sh**: Installs tmux plugins and configures tmux.
- **setup-vscode.sh**: Modifies VSCode settings for Copilot and chat features.
- **setup-git.sh**: Sets up git config, aliases, and delta integration (run only in Codespaces).
- **p10k.zsh**: Powerlevel10k theme config (not a script, just a config file).

### Order of Execution

1. system-deps.sh
2. fnm install (inline in setup.sh)
3. npm-tools.sh
4. setup-bash.sh
5. setup-zsh.sh
6. setup-fish.sh
7. setup-tmux.sh
8. setup-vscode.sh
9. setup-git.sh (conditionally)
10. Copy p10k.zsh

## What it does

- [homebrew](https://brew.sh/) package manager
  - [fzf](https://github.com/junegunn/fzf)
  - [eza](https://github.com/eza-community/eza)
  - [delta](https://github.com/dandavison/delta) (installed via cargo for latest version)
  - [zoxide](https://github.com/ajeetdsouza/zoxide) (installed via cargo for latest version)
  - [helix](https://github.com/helix-editor/helix) (installed via cargo from latest git)
- oh-my-zsh (installed by default in CodeSpaces)
  - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-autopair](https://github.com/hlissner/zsh-autopair)
  - [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
  - [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
  - Enables:
    - encode64
    - brew
    - fnm
    - gh
    - git
    - fzf
    - eza (with icons by default)
    - zoxide
- [fish](https://fishshell.com/) shell
  - [fisher](https://github.com/jorgebucaran/fisher)
  - [tide](https://github.com/IlanCosman/tide)
  - [fzf](https://github.com/PatrickF1/fzf.fish)
  - [autopair](https://github.com/jorgebucaran/autopair.fish)
  - [fish-eza](https://github.com/scaryrawr/fish-eza) (with icons by default, personal fork with `ls` using `eza`)
