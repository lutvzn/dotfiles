# Dotfiles

On Linux, create the user with a fixed UID/GID first:

```sh
sudo groupadd -g 5997 lutvzn
sudo useradd -m -u 5997 -g 5997 lutvzn
```

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

On Linux, CLI packages are installed from `~/.config/homebrew/Brewfile` via Homebrew during `chezmoi apply`.

## Quick Start

### Linux / macOS

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lutvzn
```

### Windows One-Liner (PowerShell)

```powershell
winget install twpayne.chezmoi; $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned; chezmoi init --apply lutvzn
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
chezmoi verify
```

Before applying source changes, inspect the rendered result without writing to
your home directory:

```sh
chezmoi diff
chezmoi execute-template < run_onchange_01-install-packages.sh.tmpl | bash -n
```

Installer logs are written to `~/.config/personalScripts/logs/`.

On Windows, run the same commands from PowerShell:

```powershell
chezmoi init lutvzn
chezmoi diff
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
chezmoi apply -v
```

## Pi and Node (Windows, Linux/WSL, macOS)

Node is managed **per user with fnm**, not installed system-wide. During
`chezmoi apply`, the Pi bootstrap installs Node **26**, sets `fnm default 26`,
and selects that default before installing Pi **1.0.4** and the pinned plugins.
Windows provisions `Schniz.fnm` and Git Bash through Winget. Linux provisions
fnm through Homebrew. On macOS, the Pi bootstrap uses an existing Homebrew
installation or the official fnm installer (without modifying shell profiles).
The rest of the repository's Unix package provisioning remains Linux-only.
For macOS without Homebrew, ensure `curl`, `unzip`, and Git are available first.

Pi is installed with npm into a stable user-local prefix, `~/.local/share/pi`,
independent of fnm's version-specific Node directories. Bash, Zsh, Fish,
PowerShell, and Nushell initialize fnm and select its default at startup.
Automatic directory-based Node switching is intentionally disabled so Node 26
remains selected wherever you launch Pi; use `fnm use <version>` explicitly for
projects needing another version. Open a new terminal after applying.
WSL is a separate Linux installation: apply these dotfiles inside each distro.
Non-interactive shells that skip profiles must initialize fnm explicitly.

Managed Pi files:

- `~/.pi/agent/settings.json`: provider/model defaults and pinned global plugins.
- `~/.pi/agent/pi-blackhole/pi-blackhole-config.json`: Blackhole preferences.

Only these configuration files are synced. Credentials, trust grants, sessions,
model caches, installed packages, FFF databases, and Blackhole pending memory
stay local. Applying chezmoi restores the managed preferences; changes made via
Pi's UI should be copied back to the source configuration if you want to keep them.

On a new machine, run `pi`, then `/login`. Verify with:

```sh
fnm current
node --version
pi --version
pi list
```

In Pi, use `/fff-health`, `/blackhole-memory status`, and `/vimmode` to check
plugin behavior. Try a web search using a supported authenticated model.
Project trust is still prompted normally; the bootstrap does not approve projects.

**Compatibility caveat:** the pinned Vim mode `0.9.0` and Blackhole `0.5.11`
versions load in the current setup, but their declared Pi peer-version ranges do
not cover Pi `1.0.4`. Fresh-machine and interactive compatibility still need
verification. FFF uses native bindings and must be installed on each target OS,
not copied from Windows. Blackhole memory workers remain enabled and use the
configured OpenAI model, with session-model fallback; these calls can incur charges.

Bootstrap logs:

- Unix: `~/.config/personalScripts/logs/run_onchange_after_05-setup-pi.log`
- Windows: `~/.config/personalScripts/logs/run_onchange_after_W02-setup-pi.log`

Pi and plugin versions are intentionally pinned. To upgrade, update the Pi version
in both bootstrap templates and the package versions in
`dot_pi/agent/settings.json`, review `chezmoi diff`, then apply. Node 26 resolves
to the latest available 26.x when the bootstrap runs; it is not automatically
updated on every shell startup. After changing Node's default manually, rerun the
bootstrap if you want to restore 26 as the default.

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
