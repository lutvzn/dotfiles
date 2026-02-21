# Dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

### One-line binary install, init, and apply

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER
```

### Manual installation and initialization

1. Install `chezmoi` using your package manager or the install script:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. Initialize chezmoi with this repository:
   ```sh
   chezmoi init <your-github-username>
   ```

3. Review the changes that chezmoi will make:
   ```sh
   chezmoi diff
   ```

4. Apply the changes:
   ```sh
   chezmoi apply -v
   ```

## Usage

### Adding new dotfiles

```sh
chezmoi add ~/.bashrc
```

### Editing dotfiles

```sh
chezmoi edit ~/.bashrc
```

### Updating dotfiles

```sh
chezmoi update
```
