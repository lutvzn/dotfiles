# Dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

### Linux / macOS

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lutvzn
```

Manual steps:

1. Install `chezmoi` using your package manager or the install script:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. Initialize `chezmoi` with this repository:
   ```sh
   chezmoi init lutvzn
   ```

3. Review the changes that `chezmoi` will make:
   ```sh
   chezmoi diff
   ```

4. Apply the changes:
   ```sh
   chezmoi apply -v
   ```

### Windows (PowerShell)

1. Install `chezmoi` with `winget`:
   ```powershell
   winget install twpayne.chezmoi
   ```

2. Initialize `chezmoi` with this repository:
   ```powershell
   chezmoi init lutvzn
   ```

3. Review the pending changes:
   ```powershell
   chezmoi diff
   ```

4. If `chezmoi apply` fails with `execução de scripts foi desabilitada neste sistema`, allow local scripts for your user:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

5. Apply the managed files:
   ```powershell
   chezmoi apply -v
   ```

## Running Chezmoi With This Repo

Use this repository as the source state for your home directory:

1. Initialize `chezmoi` from this repo:
   ```sh
   chezmoi init lutvzn
   ```
2. Preview what will change before writing files:
   ```sh
   chezmoi diff
   ```
3. Apply the managed dotfiles to your system:
   ```sh
   chezmoi apply -v
   ```

If you already initialized this repo before and want to re-run it after pulling changes:

```sh
chezmoi update -v
```

If you are editing this repo locally and want to apply your current source state without pulling remote changes:

```sh
chezmoi apply -v
```

For a quick health check if something does not apply cleanly:

```sh
chezmoi doctor
```

On Windows, run the same commands from PowerShell:

```powershell
chezmoi init lutvzn
chezmoi diff
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
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
