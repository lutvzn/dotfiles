# AI Agents

This repository is designed to be managed and interacted with by AI agents (like Gemini CLI).

## Guidelines for Agents

- **Chezmoi Awareness**: This repository uses `chezmoi`. Always use `chezmoi` commands to manage files when possible (e.g., `chezmoi add`, `chezmoi edit`).
- **Surgical Changes**: Make precise modifications to configuration files.
- **Security**: Never commit sensitive information (API keys, secrets) to this repository. Use `chezmoi`'s password manager integration if necessary.
- **Style**: Maintain consistent formatting in dotfiles.

## Project Structure & Conventions

### Personal Scripts
- **Location**: `dot_config/personalScripts/`
- **Homebrew Installation**: `run_once_before_00-install-prereqs.sh.tmpl` installs Homebrew on Linux after ensuring base prerequisites like `git` and `curl` are present.
- **CLI Packages**: `dot_config/homebrew/Brewfile` defines the core CLI toolset.
- **Package Management**: `run_onchange_02-install-packages.sh.tmpl` reapplies the Brew bundle whenever the Brewfile changes.
- **Execution Order**: Scripts prefixed with `run_onchange_` are prioritized by `chezmoi` to ensure dependencies like Homebrew are available for other configuration tasks.
- **Logging**: Installation scripts should log their status (success/error/info) to `~/.config/personalScripts/logs/<Script-Name>.log` for troubleshooting.
