# Cloud Dots

**Cloud Dots** is a dotfiles repository specifically designed for use in [GitHub Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) and [VS Code Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories).

## Script Organization

Scripts are organized by function for clarity and maintainability:

- **setup.sh**: Main orchestrator. Runs all other scripts in the correct order.
- **setup/**: Setup scripts and helpers.
  - **setup/core/**: Bootstrap + package managers.
    - **setup/core/system-deps.sh**: Installs system-level dependencies (apt/dnf) and binary releases from GitHub.
    - **setup/core/npm-tools.sh**: Installs global npm tools (language servers, etc).
  - **setup/shells/**: Shell-specific config.
    - **setup/shells/setup-bash.sh**
    - **setup/shells/setup-zsh.sh**
    - **setup/shells/setup-fish.sh**
  - **setup/editors/**: Editor config.
    - **setup/editors/setup-neovim.sh**
    - **setup/editors/setup-helix.sh**
    - **setup/editors/setup-vscode.sh**
  - **setup/terminal/**: Terminal tools config.
    - **setup/terminal/setup-tmux.sh**
    - **setup/terminal/setup-git.sh** (no-op unless Codespaces/DevPod)
  - **setup/ai/**: AI tooling config.
    - **setup/ai/setup-claude.sh**
  - **setup/setup-editors.sh**, **setup/setup-terminal.sh**, **setup/setup-ai.sh**: Category runners.
- **p10k.zsh**: Powerlevel10k theme config file.
- **.zsh_plugins.txt**: Antidote plugin list for zsh.

### Order of Execution

1. setup/core/system-deps.sh
2. fnm install (inline in setup.sh)
3. setup/core/npm-tools.sh
4. setup/shells/setup-bash.sh
5. setup/shells/setup-zsh.sh
6. setup/shells/setup-fish.sh
7. setup/setup-editors.sh
8. setup/setup-terminal.sh
9. setup/setup-ai.sh

## What it does in Codespaces & Devcontainers

- **Automatic system package management** (apt/dnf): Installs core CLI tools for cloud development (fish, zsh, file).
- **Homebrew**: Installs development tools including fzf, eza, zoxide, ripgrep, chafa, bat, fd, git-delta, tmux, helix, neovim, lazygit, and more.
- **Binary releases from GitHub** (to ~/.local/bin):
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

