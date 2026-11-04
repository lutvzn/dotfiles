# Dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

On Linux, the first thing `chezmoi apply` does is check that `lutvzn` is `5997:5997`. If the user is missing, it is created. If it has other IDs, the apply stops, a temporary admin user is created (`u11000`, or the next free ID) and the steps to move `lutvzn` by running chezmoi as that user are printed.

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

Windows provisioning installs PowerShell 7 (`Microsoft.PowerShell`) and makes it
Windows Terminal's default profile (stable, preview, and unpackaged installations
that have been initialized). Other Terminal settings are preserved; the original
`settings.json` is backed up as `settings.json.before-powershell7.bak` before the
first change. JSON comments/formatting are not retained in the rewritten file.
If Terminal has never been opened, open it once and run the setup explicitly:

```powershell
$script = Join-Path $env:TEMP 'set-default-powershell.ps1'
chezmoi execute-template --file (Join-Path (chezmoi source-path) 'run_onchange_after_W01-set-default-powershell.ps1.tmpl') | Set-Content $script
& "$env:ProgramFiles/PowerShell/7/pwsh.exe" -NoProfile -File $script
```

Open a new Terminal tab to use PowerShell 7. This does not replace `powershell.exe`
(Windows PowerShell 5.1), change script file associations, or change SSH's shell.
Both PowerShell editions load the same managed profile, including fnm and its
default Node version.

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

`chezmoi init` asks once whether this is a **personal machine**. Answer no on
work machines, containers, or VMs to skip user creation, NetBird, and the
Forgejo login. To change it later, edit `personal` in
`~/.config/chezmoi/chezmoi.toml`.

Git identity and the GitHub/Forgejo credential helpers live in the managed
`~/.config/git/config`. `~/.gitconfig` is left alone for machine-local settings.

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
and selects that default before installing Pi **1.4.0** and the pinned plugins.
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

On Windows, `chezmoi update` runs `Repair-Fnm -Default` after Winget provisioning
and before Pi setup to ensure the fnm default is installed and working.
PowerShell startup only selects the default and loads the manual `Repair-Fnm`
command; it does not run repair checks. Plain `chezmoi apply` does not run them. With no managed default,
it installs Node 26 and sets that default. The check executes JavaScript with
Node and verifies npm/npx can run, as well as checking their launchers. Missing
or broken installations are repaired from a clean download of the exact same
Node version, preserving aliases and unrelated global packages. A healthy
`node.exe` is never replaced. Healthy checks require no downloads. Repairs
are logged to `~/.config/personalScripts/logs/Repair-Fnm.log`; failures stop
the update rather than affecting shell startup. If Windows
locks a broken executable, close processes using it and retry. After manually
switching versions with `fnm use`, run `Repair-Fnm` to check that version.

Managed Pi files:

- `~/.pi/agent/settings.json`: provider/model defaults and pinned global plugins,
  merged from `.chezmoitemplates/pi-settings.json`; keys Pi writes itself
  (such as `deviceId`) stay local to each machine.
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
`.chezmoitemplates/pi-settings.json`, review `chezmoi diff`, then apply. Node 26 resolves
to the latest available 26.x when the bootstrap runs; it is not automatically
updated on every shell startup. After changing Node's default manually, rerun the
bootstrap if you want to restore 26 as the default.

## NetBird

Vaultwarden (`https://vault.lct.st`) is only reachable over NetBird, so
`run_onchange_after_06-setup-netbird.sh` (Linux) and
`run_onchange_after_W04-setup-netbird.ps1` (Windows) run before the git forge
logins. On Linux the script installs NetBird with the official installer
(`https://pkgs.netbird.io/install.sh`); Windows installs it through Winget.
Both then run `netbird up`: open the printed URL (or the browser window) to
approve the machine, or export `NB_SETUP_KEY` beforehand to join unattended.
The script waits up to 60 seconds for Vaultwarden to answer and fails otherwise,
which stops `chezmoi apply` before the git forge logins.

On rpm-ostree systems NetBird is layered into the next deployment: reboot and
re-run `chezmoi apply`. Logs: `~/.config/personalScripts/logs/run_onchange_after_06-setup-netbird.log`
(Windows: `run_onchange_after_W04-setup-netbird.log`).

## Git forges (GitHub and git.lct.st)

After provisioning, `run_onchange_after_07-login-git-forges.sh` (Linux) and
`run_onchange_after_W05-login-git-forges.ps1` (Windows) log `gh` in to GitHub
and, on personal machines, `tea` in to `https://git.lct.st` and install the SSH
commit signing key and the SSH login key. The managed git config already uses gh
and tea as credential helpers for those hosts and signs every commit and tag on
personal machines, and the managed `~/.ssh/config` (personal machines only) makes
ssh use the login key, so HTTPS git, the `gh`/`tea` CLIs, signed commits, and SSH
work as soon as `chezmoi apply` finishes. Logins and keys that already work are left alone.

On personal machines the tokens and the SSH keys come from Bitwarden
(Vaultwarden at `https://vault.lct.st`), unlocked once for all of them:

1. In GitHub, create a classic personal access token under Settings → Developer
   settings with `repo`, `read:org`, `gist`, and `workflow`. Store it as the
   **password** of a Bitwarden item named `github.com access token`.
2. In Forgejo, create an access token under Settings → Applications with
   `write:repository`, `write:issue`, `read:user`, and `read:organization`.
   Store it as the **password** of a Bitwarden item named
   `git.lct.st access token`.
3. In Bitwarden, create an **SSH key** item named `lutvzn git signing key`
   (Bitwarden generates an Ed25519 key). Register its public key once on each
   forge:
   - GitHub: Settings → SSH and GPG keys → New SSH key, key type **Signing Key**.
   - Forgejo: Settings → SSH / GPG keys → Add key, then **Verify** it as
     prompted. Forgejo only marks commits verified when the committer email
     (`106083845+lutvzn@users.noreply.github.com`) is an activated email on
     your account.
4. In Bitwarden, create an **SSH key** item named `lutvzn_nopass_ssh` without a
   passphrase, and add its public key to `~/.ssh/authorized_keys` on the hosts
   you log in to (and as an **Authentication Key** on the forges for SSH git).

Create the signing key item before applying on a personal machine: git is set
to sign every commit, so commits fail until the key is installed. To skip
signing for one commit, use `git -c commit.gpgsign=false commit`.

During apply, the script logs in to or unlocks Bitwarden (prompting for your
master password), reads the tokens and key, locks the vault again, runs
`gh auth login --with-token` and `tea login add`, and writes the key to
`~/.ssh/git_signing_ed25519` (plus `.pub`) and `~/.ssh/allowed_signers`, which
lets `git log --show-signature` verify commits locally, and the login key to
`~/.ssh/lutvzn_nopass_ssh` (plus `.pub`). To run unattended, export an
unlocked `BW_SESSION` first. If the GitHub item is missing, and on non-personal
machines (which cannot reach Vaultwarden), `gh` falls back to its browser login.
gh stores its token in the system keyring and tea in `~/.config/tea/config.yml`;
none of these secrets are stored in this repository. Logs:
`~/.config/personalScripts/logs/run_onchange_after_07-login-git-forges.log`
(Windows: `run_onchange_after_W05-login-git-forges.log`).

The script is a `run_onchange_` script, so it only reruns by itself when its
contents change. After rotating a token or an SSH key in Bitwarden, delete
the old key files (for a key) and run it directly:

```sh
bash <(chezmoi execute-template < "$(chezmoi source-path)/run_onchange_after_07-login-git-forges.sh.tmpl")
```

Commits use the same git email as GitHub. Add
`106083845+lutvzn@users.noreply.github.com` as an email on your Forgejo
account so pushed commits link to it.

## Dotfiles Doctor

After applying and opening a new terminal, run:

```sh
dotfiles-doctor
```

Works in PowerShell/cmd on Windows and Bash, Zsh, Fish, or Nushell on Unix.
The command checks required tools (`chezmoi`, Git, fnm, Node, npm, Pi), Node 26
and fnm's default/current versions, the stable Pi prefix, configured npm plugin
versions, and multiple installations on PATH. Pi's declared plugin peer ranges
are displayed for manual review, not automatically evaluated.

This is read-only: no installs, network requests, authentication, config changes,
or shell initialization. It does not read credentials or sessions, and it does
not replace interactive plugin testing. Exit code is **1** for failed checks and
**0** otherwise; warnings alone do not fail the command.

The doctor itself needs Node. If Node is missing, its launcher reports that
problem and exits. To check a fresh machine before Node is available, use
`chezmoi doctor`. For file drift, use `chezmoi verify` separately.

Direct invocation (including shells without profile loading):

```sh
node ~/.config/personalScripts/dotfiles-doctor.cjs
```

On PowerShell:

```powershell
node "$HOME/.config/personalScripts/dotfiles-doctor.cjs"
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
