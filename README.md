# Cloud Dots

**Cloud Dots** provides development environment customizations for [GitHub Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account), [VS Code Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories), [Microsoft Dev Box](https://devbox.microsoft.com), and [Copilot cloud sandboxes](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/personalize-cloud-sessions).

The root-level [workload.yaml](workload.yaml) is the self-contained Microsoft Dev Box customization definition uploaded to Dev Box. Repositories are cloned under the user-level `GithubLocation` environment variable when set and fall back to `$HOME\GitHub` otherwise.

## Copilot cloud sandboxes

The root [`.copilot/settings.json`](.copilot/settings.json) is a minimal, separate profile for cloud sandboxes. It enables the ScaryPilot behavior and workflow plugins: Anti-Slop, Copilot Autoresearch, Digivolution, and pstack. It does not include Herdr, Azure DevOps, OMLX/local LLM integrations, desktop notifications, or local LSP configuration. The full Codespaces/Devcontainer profile remains in `setup/config/copilot/`, and Dev Box settings remain in `workload.yaml`.

Enable dotfiles in your personal **Copilot > Cloud** settings and select this repository (the selection is shared with Codespaces). Start or resume a **Cloud** session to apply changes; GitHub Actions-based sessions do not use this personalization.

Copilot copies the entire dotfiles repository into the sandbox's home directory, including `.copilot/`, but does not run `setup.sh` or any other installer. Keep this profile ready to use without setup scripts. Plugin fetching and any runtime downloads remain subject to the sandbox's network allowlist. Anti-Slop needs Node.js/npm and registry access for its first lint run; Autoresearch and Digivolution require a host with Copilot native extension support. Optional pstack workflows still require their documented tools (such as Bun, Java/TLC, or `gh-stack`); this profile does not install them.

## Script Organization

Scripts are organized by function for clarity and maintainability:

- **setup.sh**: Main orchestrator. Runs all other scripts in the correct order.
- **workload.yaml**: Microsoft Dev Box customization workload.
- **setup/**: Setup scripts and helpers.
  - **setup/core/**: Bootstrap + package managers.
    - **setup/core/system-deps.sh**: Installs system-level dependencies (apt/dnf) and Bun.
    - **setup/core/homebrew.sh**: Installs Homebrew and development tools.
    - **setup/core/npm-tools.sh**: Installs global npm tools (language servers, etc).
  - **setup/shells/**: Shell-specific config.
    - **setup/shells/setup-bash.sh**
    - **setup/shells/setup-zsh.sh**
    - **setup/shells/setup-fish.sh**
  - **setup/editors/**: Editor config.
    - **setup/editors/setup-neovim.sh**
    - **setup/editors/setup-vscode.sh**
  - **setup/terminal/**: Terminal tools config.
    - **setup/terminal/setup-herdr.sh**
    - **setup/terminal/setup-git.sh** (no-op unless Codespaces/DevPod): Wires [hunk](https://github.com/modem-dev/hunk) as the git pager and difftool; delta stays for `git add -p` and fzf previews.
    - **setup/terminal/setup-bat.sh**: Configures bat theme.
  - **setup/ai/**: AI tooling config.
    - **setup/ai/setup-copilot.sh**: Configures Copilot CLI plugins from the ScaryPilot marketplace.
  - **setup/shims/**: Command wrapper scripts symlinked to `~/.local/bin/`.
  - **setup/setup-editors.sh**, **setup/setup-terminal.sh**, **setup/setup-ai.sh**, **setup/setup-shims.sh**: Category runners.
- **p10k.zsh**: Powerlevel10k theme config file.
- **.zsh_plugins.txt**: Antidote plugin list for zsh.

### Order of Execution

1. setup/core/system-deps.sh
2. setup/core/homebrew.sh
3. fnm install (inline in setup.sh)
4. setup/core/npm-tools.sh
5. setup/shells/setup-bash.sh
6. setup/shells/setup-zsh.sh
7. setup/shells/setup-fish.sh
8. setup/setup-editors.sh
9. setup/setup-terminal.sh
10. setup/setup-ai.sh
11. setup/setup-shims.sh

## What it does in Codespaces & Devcontainers

- **Automatic system package management** (apt/dnf): Installs core CLI tools for cloud development (fish, zsh, file), and Bun.
- **Homebrew**: Installs development tools including ast-grep, fzf, eza, zoxide, ripgrep, chafa, bat, fd, git-delta, hunk, Herdr, neovim, marksman, copilot-cli, worktrunk, sl, and xclip.
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
  - [copilot.fish](https://github.com/scaryrawr/copilot.fish)
- **npm tools**: typescript, typescript-language-server, vscode-langservers-extracted, pyright, @typescript/native-preview
- **AI tools**: copilot-cli and Herdr (via Homebrew), with ScaryPilot plugins for Azure DevOps and local OMLX media workflows plus the Herdr integration for Copilot CLI.
