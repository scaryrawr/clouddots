# Cloud Dots

**Cloud Dots** is a dotfiles repository specifically designed for use in [GitHub Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) and [VS Code Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories).

## Script Organization

Scripts are now organized by function for clarity and maintainability:

- **setup.sh**: Main orchestrator. Runs all other scripts in the correct order.
- **system-deps.sh**: Installs system-level dependencies (apt/dnf/cargo/go/opencode).
- **npm-tools.sh**: Installs global npm tools (language servers, etc).
- **setup-bash.sh**: Configures bash environment and PATH.
- **setup-zsh.sh**: Configures zsh, oh-my-zsh plugins, powerlevel10k, etc.
- **setup-fish.sh**: Configures fish, Fisher plugins, fnm, zoxide, fzf, eza, tmux, etc.
- **setup-tmux.sh**: Installs tmux plugins and configures tmux.
- **setup-vscode.sh**: Modifies VSCode settings for Copilot and chat features.
- **setup-neovim.sh**: Clones or updates neovim configuration from lazyvim.
- **setup-opencode.sh**: Configures opencode CLI tool with MCP and theme settings.
- **setup-git.sh**: Sets up git config, aliases, and delta integration (run only in Codespaces).
- **p10k.zsh**: Powerlevel10k theme config (not a script, just a config file).

### Order of Execution

1. system-deps.sh
2. fnm install (inline in setup.sh)
3. npm-tools.sh
4. setup-bash.sh
5. setup-zsh.sh
6. setup-fish.sh
7. setup-neovim.sh
8. setup-tmux.sh
9. setup-vscode.sh
10. setup-opencode.sh
11. setup-git.sh (conditionally)
12. Copy p10k.zsh

## What it does in Codespaces & Devcontainers

- **Automatic system package management** (apt/dnf): Installs core CLI tools for cloud development (fish, zsh, ripgrep, fzf, file, chafa, bat, fd-find, tmux, neovim).
- **Binary releases from GitHub** (to ~/.local/bin):
  - [fzf](https://github.com/junegunn/fzf)
  - [eza](https://github.com/eza-community/eza)
  - [delta](https://github.com/dandavison/delta)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
  - [helix](https://github.com/helix-editor/helix) (`hx`)
  - [lazygit](https://github.com/jesseduffield/lazygit)
  - [opencode](https://github.com/scaryrawr/opencode)
- **oh-my-zsh** (default in Codespaces):
  - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-autopair](https://github.com/hlissner/zsh-autopair)
  - [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
  - [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
  - Enables: encode64, fnm, gh, git, fzf, eza (with icons), zoxide
- **fish shell**:
  - [fisher](https://github.com/jorgebucaran/fisher)
  - [tide](https://github.com/IlanCosman/tide)
  - [fzf](https://github.com/PatrickF1/fzf.fish)
  - [autopair](https://github.com/jorgebucaran/autopair.fish)
  - [fish-eza](https://github.com/scaryrawr/fish-eza) (with icons, custom `ls`)