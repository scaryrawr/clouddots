# Cloud Dots

**Cloud Dots** is a dotfiles repository specifically designed for use in [GitHub Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) and [VS Code Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories).

## Script Organization

Scripts are organized by function for clarity and maintainability:

- **setup.sh**: Main orchestrator. Runs all other scripts in the correct order.
- **system-deps.sh**: Installs system-level dependencies (apt/dnf) and binary releases from GitHub.
- **npm-tools.sh**: Installs global npm tools (language servers, etc).
- **setup-bash.sh**: Configures bash environment and PATH.
- **setup-zsh.sh**: Configures zsh with antidote plugin manager, powerlevel10k, and oh-my-zsh plugins.
- **setup-fish.sh**: Configures fish shell with Fisher, tide prompt, and various plugins.
- **setup-tmux.sh**: Installs tmux plugins and configures tmux.
- **setup-vscode.sh**: Modifies VSCode settings for Copilot and chat features.
- **setup-neovim.sh**: Clones or updates neovim configuration from lazyvim.
- **setup-helix.sh**: Clones or updates helix editor configuration.
- **setup-git.sh**: Sets up git config, aliases, and delta integration (run only in Codespaces/DevPod).
- **p10k.zsh**: Powerlevel10k theme config file.
- **.zsh_plugins.txt**: Antidote plugin list for zsh.

### Order of Execution

1. system-deps.sh
2. fnm install (inline in setup.sh)
3. npm-tools.sh
4. setup-bash.sh
5. setup-zsh.sh
6. setup-fish.sh
7. setup-neovim.sh
8. setup-helix.sh
9. setup-tmux.sh
10. setup-vscode.sh
11. setup-git.sh (conditionally in Codespaces/DevPod)

## What it does in Codespaces & Devcontainers

- **Automatic system package management** (apt/dnf): Installs core CLI tools for cloud development (fish, zsh, ripgrep, helix, fzf, file, chafa, bat, fd-find, tmux, neovim).
- **Binary releases from GitHub** (to ~/.local/bin):
  - [fzf](https://github.com/junegunn/fzf)
  - [eza](https://github.com/eza-community/eza)
  - [delta](https://github.com/dandavison/delta)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
  - [lazygit](https://github.com/jesseduffield/lazygit)
  - [magus](https://github.com/scaryrawr/magus)
- **zsh** with [antidote](https://github.com/mattmc3/antidote) plugin manager:
  - [powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
  - [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
  - [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
  - oh-my-zsh plugins: encode64, docker, docker-compose, fnm, gh, bun, golang, cp, eza, rust, yarn, zoxide
- **fish shell**:
  - [fisher](https://github.com/jorgebucaran/fisher)
  - [tide](https://github.com/IlanCosman/tide) prompt
  - [fzf.fish](https://github.com/scaryrawr/fzf.fish)
  - [fish-eza](https://github.com/scaryrawr/fish-eza) (with icons)
  - [zoxide.fish](https://github.com/scaryrawr/zoxide.fish)
  - [tmux.fish](https://github.com/scaryrawr/tmux.fish)
  - [copilot.fish](https://github.com/scaryrawr/copilot.fish)
- **npm tools**: typescript, typescript-language-server, vscode-langservers-extracted, pyright, @github/copilot, @typescript/native-preview

