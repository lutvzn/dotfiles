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
- **Package Management**: `run_onchange_01-install-packages.sh.tmpl` reapplies the Brew bundle whenever the Brewfile changes.
- **Shared Helpers**: Linux run scripts include `.chezmoitemplates/common.sh` (`log_message`, `source_brew_environment`, `run_with_sudo`); Windows run scripts include `.chezmoitemplates/write-log.ps1`. Set the log file after the include.
- **Machine Data**: `.chezmoi.toml.tmpl` prompts once for `personal`. User creation, NetBird, the Forgejo login (and its git credential helper), SSH commit signing, and the SSH login key (with `~/.ssh/config`) run only when it is true; the GitHub login runs everywhere.
- **Bitwarden**: Linux run scripts that read secrets include `.chezmoitemplates/bitwarden.sh` after `common.sh` (`bitwarden_unlock`, `bitwarden_password`, `bitwarden_lock`); Windows scripts include `.chezmoitemplates/bitwarden.ps1` after `write-log.ps1` (`Unlock-Bitwarden`, `Get-BitwardenPassword`, `Lock-Bitwarden`).
- **Git Config**: `dot_config/git/config.tmpl` manages identity and credential helpers declaratively; do not add `git config --global` calls to run scripts.
- **Execution Order**: Scripts prefixed with `run_onchange_` are prioritized by `chezmoi` to ensure dependencies like Homebrew are available for other configuration tasks.
- **Logging**: Installation scripts should log their status (success/error/info) to `~/.config/personalScripts/logs/<Script-Name>.log` for troubleshooting.
