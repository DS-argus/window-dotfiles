# Windows CLI Configuration

Windows CLI dotfiles for a PowerShell 7 based environment. This repo is intended to live at:

```ps1
$HOME\.config
```

## Tools

- Windows package manager: `scoop`
- Emulator: `alacritty`, optional `wezterm`
- Multiplexer: `psmux`
- Editor: `neovim`
- Notes editor: `obsidian` with Vim mode
- Shell: `PowerShell 7`
- File manager: `yazi`
- Prompt: `starship`
- CLI tools: `git`, `gh`, `lazygit`, `eza`, `bat`, `btop`, `fzf`, `zoxide`, `ripgrep`, `fd`, `uv`, `csvlens`, `ffmpeg`, `7zip`, `jq`, `poppler`, `resvg`, `imagemagick`, `tree-sitter`, `mingw`, `nodejs-lts`

## Installation

Install Scoop from normal non-admin PowerShell:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

If the install fails, use the official instructions: https://github.com/ScoopInstaller/Install

If you are running elevated/admin PowerShell, follow the official `-RunAsAdmin` guidance from that repo.

Add buckets and install `git` before cloning:

```ps1
scoop bucket add extras
scoop bucket add nerd-fonts

scoop install git
```

Move any existing non-empty `~\.config` to a timestamped backup, clone this repo, then restore Scoop's runtime-local `.config\scoop` directory if Scoop created it before the clone. `scoop/` is gitignored.

```ps1
$configPath = Join-Path $HOME '.config'
$backupPath = $null

if (Test-Path -LiteralPath $configPath) {
  $hasContent = @(Get-ChildItem -LiteralPath $configPath -Force -ErrorAction SilentlyContinue).Count -gt 0
  if ($hasContent) {
    $backupPath = "$configPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $configPath -Destination $backupPath
    Write-Host "Backed up existing .config to $backupPath"
  } else {
    Remove-Item -LiteralPath $configPath -Force
  }
}

git clone https://github.com/DS-argus/window-dotfiles.git $configPath
Set-Location $configPath

if ($backupPath -and (Test-Path -LiteralPath "$backupPath\scoop")) {
  Move-Item -LiteralPath "$backupPath\scoop" -Destination "$configPath\scoop"
}
```

Install the remaining packages:

```ps1
scoop install `
  pwsh psmux starship yazi neovim `
  gh lazygit `
  ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick `
  tree-sitter mingw `
  btop bat eza uv csvlens nodejs-lts `
  JetBrainsMono-NF D2Coding-NF
```

Install one or both terminal emulators:

```ps1
scoop install alacritty wezterm
```

Reference versions:

| Tool              | Version                                            |
| ----------------- | -------------------------------------------------- |
| `git`             | `2.54.0`                                           |
| `pwsh`            | `7.6.2`                                            |
| `neovim`          | `0.12.2`                                           |
| `nvim-treesitter` | `main`, `4916d6592ede8c07973490d9322f187e07dfefac` |
| `tree-sitter`     | `0.26.9`                                           |
| `mingw`           | `16.1.0-rt_v14-rev1`                               |
| `yazi`            | `26.5.6`                                           |
| `starship`        | `1.26.0`                                           |
| `psmux`           | `3.3.6`                                            |
| `alacritty`       | `0.17.0`                                           |

## Links

Create runtime links and the PowerShell profile stub:

```ps1
Set-Location "$HOME\.config"

function Backup-Path {
  param([Parameter(Mandatory)] [string] $Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  $item = Get-Item -LiteralPath $Path -Force
  if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
    Remove-Item -LiteralPath $Path -Force
    return
  }

  $backup = "$Path.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
  Move-Item -LiteralPath $Path -Destination $backup
}

function New-DotfileJunction {
  param(
    [Parameter(Mandatory)] [string] $Path,
    [Parameter(Mandatory)] [string] $Target
  )

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
  Backup-Path $Path
  New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
}

function New-DotfileSymlink {
  param(
    [Parameter(Mandatory)] [string] $Path,
    [Parameter(Mandatory)] [string] $Target
  )

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
  Backup-Path $Path
  New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
}

function New-PowerShellProfileStub {
  $profilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profilePath) | Out-Null
  Backup-Path $profilePath

  @'
$repoProfile = Join-Path $HOME '.config\powershell\Microsoft.PowerShell_profile.ps1'
if (Test-Path -LiteralPath $repoProfile) {
    . $repoProfile
}
'@ | Set-Content -LiteralPath $profilePath -Encoding UTF8
}

New-DotfileJunction "$env:LOCALAPPDATA\nvim" "$HOME\.config\nvim"
New-DotfileJunction "$env:APPDATA\alacritty" "$HOME\.config\alacritty"

if (-not (Test-Path -LiteralPath "$HOME\.config\git\.gitconfig")) {
  Copy-Item "$HOME\.config\git\.gitconfig.local.example" "$HOME\.config\git\.gitconfig"
}

New-DotfileSymlink "$HOME\.gitconfig" "$HOME\.config\git\.gitconfig"
New-DotfileSymlink "$HOME\.wezterm.lua" "$HOME\.config\wezterm\wezterm.lua"

$windowsTerminalPackage = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe'
if (Test-Path -LiteralPath $windowsTerminalPackage) {
  New-DotfileSymlink `
    (Join-Path $windowsTerminalPackage 'LocalState\settings.json') `
    "$HOME\.config\windows-terminal\settings.json"
} else {
  Write-Warning 'Windows Terminal Stable package was not found; skipped its settings link.'
}

New-PowerShellProfileStub
```

Symbolic links may require Developer Mode or admin PowerShell. The PowerShell profile uses a real stub file instead of a symlink.

The Windows Terminal path above is for the Stable Store/MSIX package. Preview, Canary, and unpackaged distributions use different settings paths. Only `settings.json` is linked; machine-local files such as `state.json` and `elevated-state.json` must not be linked or copied.

## Post-install

Install psmux plugins:

```ps1
New-Item -ItemType Directory -Force -Path "$HOME\.psmux\plugins" | Out-Null

Remove-Item "$env:TEMP\psmux-plugins" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$HOME\.psmux\plugins\ppm" -Recurse -Force -ErrorAction SilentlyContinue

git clone https://github.com/psmux/psmux-plugins.git "$env:TEMP\psmux-plugins"
Copy-Item "$env:TEMP\psmux-plugins\ppm" "$HOME\.psmux\plugins\ppm" -Recurse -Force
Remove-Item "$env:TEMP\psmux-plugins" -Recurse -Force
```

Start psmux, then press `Ctrl+a` followed by `Shift+i` (`Prefix + I`) to install the declared plugins. This is PPM's supported bootstrap flow; do not run `install_plugins.ps1` before the first psmux session.

```ps1
psmux new-session -s setup
```

After installation, press `Ctrl+a` followed by `r` to reload the config, or exit and create the session again so the installed plugin is loaded.

If `psmux new-session` opens a blank screen, update psmux first. Version 3.3.6 fixes [a Windows environment-block bug](https://github.com/psmux/psmux/issues/167) that could prevent the pane shell from starting on only some machines.

```ps1
scoop update psmux
psmux --version  # tmux 3.3.6 or newer
(Get-Command pwsh -ErrorAction Stop).Source

# Ignore every user config and PowerShell profile for one isolated smoke test.
psmux -L psmux-smoke -f NUL new-session -s smoke -- pwsh -NoLogo -NoProfile

# Read the concrete shell-spawn error, if psmux recorded one.
Get-Content "$HOME\.psmux\server-startup.log" -ErrorAction SilentlyContinue

# From a second terminal, see which process owns a live-but-blank pane.
psmux list-panes -a -F '#{session_name} cmd=#{pane_current_command} dead=#{pane_dead}'

# psmux uses only the first existing config in this order.
@(
  "$HOME\.psmux.conf"
  "$HOME\.psmuxrc"
  "$HOME\.tmux.conf"
  "$HOME\.config\psmux\psmux.conf"
) | Where-Object { Test-Path -LiteralPath $_ }
```

If the isolated smoke test is still blank on 3.3.6, [issue #450](https://github.com/psmux/psmux/issues/450) matches the blinking-cursor symptom. Its standard-handle race is fixed on master by [`06247bf`](https://github.com/psmux/psmux/commit/06247bfa25e254f1e7657ee8d7323fd3a950fb67); use a newer release containing that commit when available.

If the isolated smoke test works, psmux itself is healthy. The first config printed by the last command, or the normal PowerShell profile, is then the startup blocker.

Install Yazi packages:

```ps1
ya pkg install
```

Set local Git identity in the ignored config created from the tracked example:

```ps1
nvim "$HOME\.config\git\.gitconfig"
```

Local Git aliases and `[user]` identity live in ignored `git/.gitconfig`. Only `git/.gitconfig.local.example` is tracked as the template.

Set up GitHub CLI:

```ps1
gh auth login
gh extension install dlvhdr/gh-dash
```

Set up Neovim:

```vim
:Lazy sync
:MasonInstall lua-language-server pyright rust-analyzer ruff stylua prettier gopls goimports
```

Set up Obsidian Vim bindings by copying or linking `obsidian/.obsidian.vimrc` into the vault root that uses the Vimrc plugin.

`STARSHIP_CONFIG`, `YAZI_CONFIG_HOME`, `YAZI_FILE_ONE`, `EDITOR`, `VISUAL`, and `GIT_EDITOR` are already set by `powershell/cli-init.ps1`.

`YAZI_FILE_ONE` uses Scoop Git's `file.exe` first, then the Program Files Git fallback if present.

Neovim 0.12 uses `nvim-treesitter` `main`; `tree-sitter` and `mingw` are required to avoid Markdown Treesitter/render-markdown failures.

Verify the shell environment:

```ps1
$PSVersionTable.PSEdition  # Core
$PROFILE                   # ...\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
$env:STARSHIP_CONFIG
$env:STARSHIP_SHELL        # pwsh
$env:YAZI_CONFIG_HOME
$env:YAZI_FILE_ONE
Get-Command starship
Get-Command nvim
```

## Managed Paths

| Repo path                                     | Runtime path                                                          | Method                          |
| --------------------------------------------- | --------------------------------------------------------------------- | ------------------------------- |
| `alacritty/`                                  | `%APPDATA%\alacritty`                                                 | `Junction`                      |
| `nvim/`                                       | `%LOCALAPPDATA%\nvim`                                                 | `Junction`                      |
| `git/.gitconfig.local.example`                | `git/.gitconfig` then `%USERPROFILE%\.gitconfig`                      | `local copy, then SymbolicLink` |
| `powershell/Microsoft.PowerShell_profile.ps1` | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | `profile stub`                  |
| `wezterm/wezterm.lua`                         | `%USERPROFILE%\.wezterm.lua`                                          | `SymbolicLink`                  |
| `windows-terminal/settings.json`              | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` | `SymbolicLink (Stable)`         |
| `psmux/psmux.conf`                            | `%USERPROFILE%\.config\psmux\psmux.conf`                              | `default path`                  |
| `scoop/config.json`                           | `%USERPROFILE%\.config\scoop\config.json`                             | `default path`                  |
| `gh-dash/config.yml`                          | `%USERPROFILE%\.config\gh-dash\config.yml`                            | `default path`                  |
| `starship/starship.toml`                      | `STARSHIP_CONFIG`                                                     | `environment variable`          |
| `yazi/`                                       | `YAZI_CONFIG_HOME`                                                    | `environment variable`          |
| `obsidian/.obsidian.vimrc`                    | `<vault>\.obsidian.vimrc`                                             | `manual per vault`              |
