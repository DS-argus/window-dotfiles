# A Polished WezTerm-First Windows CLI Setup

This repository holds my Windows CLI dotfiles, built around `WezTerm`, `PowerShell 7`, `Yazi`, and `Neovim`.

The layout is simple:

- Keep the repo at `$HOME\.config`
- Use the default PowerShell 7 profile path in `Documents\PowerShell` to source the repo profile
- Point a few runtime paths at the repo with symlinks or a junction
- Keep app-specific config inside this repository whenever possible

## Included

- `WezTerm` as the main terminal
- `PowerShell 7` as the default shell
- `Starship` for the prompt
- `Yazi` for file management
- `Neovim` for editing
- `git`, `lazygit`, `gh`, and `gh-dash`
- `eza`, `bat`, `btop`, `fzf`, `zoxide`, `ripgrep`, `fd`, `uv`, and `csvlens`

## Setup

```powershell
# 1) Install Scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 2) Add Scoop buckets
scoop bucket add extras
scoop bucket add nerd-fonts

# 3) Install terminal, shell, fonts, and CLI tools
scoop install `
  git pwsh wezterm starship yazi `
  ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick `
  btop bat eza uv lazygit gh neovim csvlens nodejs-lts `
  JetBrainsMono-NF D2Coding-NF

# 4) Clone this repo
git clone <your-repo-url> $HOME\.config
Set-Location $HOME\.config

# 5) Point WezTerm at the repo config
New-Item -ItemType SymbolicLink -Path "$HOME\.wezterm.lua" -Target "$HOME\.config\wezterm\wezterm.lua" -Force

# 6) Create the default PowerShell 7 profile and source the repo profile
New-Item -ItemType Directory -Force -Path "$HOME\Documents\PowerShell" | Out-Null
# PowerShell already checks this default profile path; this file just forwards to the repo
@'
$repoProfile = Join-Path $HOME '.config\powershell\Microsoft.PowerShell_profile.ps1'

if (Test-Path -LiteralPath $repoProfile) {
    . $repoProfile
}
'@ | Set-Content -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# 7) Point Git and Neovim at the repo-managed config
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$HOME\.config\git\.gitconfig" -Force
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\.config\nvim" -Force

# 8) Set your Git identity
Copy-Item "$HOME\.config\git\.gitconfig.local.example" "$HOME\.config\git\.gitconfig.local"
# Then edit git/.gitconfig.local with your own name and email

# 9) Install gh-dash
gh auth login
gh extension install dlvhdr/gh-dash

# 10) Open WezTerm
# It will start a fresh PowerShell 7 session with this config loaded
```

## Post-Install Neovim Setup

`lazy.nvim` bootstraps itself on first launch, but Mason tools are not auto-installed on startup in this config.

Open `nvim` once, then run:

```vim
:Lazy sync
:MasonInstall lua-language-server pyright rust-analyzer ruff stylua prettier
```

## Managed Paths

| Repo path | Runtime path |
| --- | --- |
| `wezterm/wezterm.lua` | `%USERPROFILE%\.wezterm.lua` |
| `powershell/Microsoft.PowerShell_profile.ps1` | sourced from `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| `starship/starship.toml` | `%USERPROFILE%\.config\starship\starship.toml` via `STARSHIP_CONFIG` |
| `yazi/` | `%USERPROFILE%\.config\yazi` via `YAZI_CONFIG_HOME` |
| `git/.gitconfig` | `%USERPROFILE%\.gitconfig` |
| `git/.gitconfig.local` | local-only Git identity file, included by `git/.gitconfig` |
| `nvim/` | `%LOCALAPPDATA%\nvim` |

## Notes

- This setup assumes the repository lives at `$HOME\.config`.
- `WezTerm` starts `pwsh.exe` by default.
- `PowerShell` exports `STARSHIP_CONFIG` and `YAZI_CONFIG_HOME` from the repo profile.
- The `y` PowerShell function wraps `yazi` and updates the current working directory when you quit.
- `JetBrainsMono Nerd Font` is the main font. `D2CodingLigature Nerd Font` is used as a Korean fallback.
- `git/.gitconfig.local` is intentionally ignored and should contain your personal Git identity.
- `SymbolicLink` creation may require Windows Developer Mode or an elevated shell.
- `Node.js` comes from `scoop install nodejs-lts` in this setup and is required for some Neovim tooling, especially `pyright`.
