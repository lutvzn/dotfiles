# AI Agents

This repository is designed to be managed and interacted with by AI agents (like Gemini CLI).

## Guidelines for Agents

- **Chezmoi Awareness**: This repository uses `chezmoi`. Always use `chezmoi` commands to manage files when possible (e.g., `chezmoi add`, `chezmoi edit`).
- **Surgical Changes**: Make precise modifications to configuration files.
- **Security**: Never commit sensitive information (API keys, secrets) to this repository. Use `chezmoi`'s password manager integration if necessary.
- **Style**: Maintain consistent formatting in dotfiles.
