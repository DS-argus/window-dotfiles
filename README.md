# Windows Dotfiles

PowerShell, Windows Terminal, Neovim, Yazi, GlazeWM, and Zebar configuration for Windows 11.

The repository must be cloned to `%USERPROFILE%\.config`.

## Install

Requirements:

- Windows 11
- PowerShell
- Git
- Windows Terminal Stable
- Windows Developer Mode or an elevated shell for symbolic links

Back up an existing `.config`, clone the repository, and run the setup script:

```powershell
$config = Join-Path $HOME '.config'
$backup = $null

if (Test-Path $config) {
    $backup = "$config.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item $config $backup
}

git clone https://github.com/DS-argus/window-dotfiles.git $config

if ($backup -and (Test-Path "$backup\scoop")) {
    Move-Item "$backup\scoop" "$config\scoop"
}

& "$config\setup.ps1"
```

The backup is preserved. Restore any other files you still need after installation.

## Setup script

`setup.ps1` can be run repeatedly. It:

- Installs Scoop when missing
- Reuses Git from PATH, Scoop, or a Git for Windows installation
- Installs or updates the required Scoop packages and installs Leaf when missing
- Connects the PowerShell, Git, Windows Terminal, Neovim, Yazi, and Leaf configs
- Configures GlazeWM and Zebar
- Registers `GLAZEWM_CONFIG_PATH`
- Adds GlazeWM to Windows startup
- Installs Yazi packages
- Backs up conflicting managed paths as `.backup.<timestamp>`

Each stage prints the actions it will perform and waits for `y` or `n`. Package failures are reported and skipped so the remaining packages can continue.

Optional flags:

```powershell
& "$HOME\.config\setup.ps1" -SkipPackages
& "$HOME\.config\setup.ps1" -SkipUpdates        # keep installed packages at their current version
& "$HOME\.config\setup.ps1" -SkipWindowManager
& "$HOME\.config\setup.ps1" -Yes                # approve every stage
```

## After installation

Set the local Git identity and authenticate GitHub CLI:

```powershell
nvim "$HOME\.config\git\.gitconfig"
gh auth login
```

Open a new PowerShell session to load the profile. GlazeWM and Zebar start automatically at the next sign-in.

Reload GlazeWM after editing its configuration:

```powershell
glazewm command wm-reload-config
```
