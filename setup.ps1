[CmdletBinding()]
param(
    [switch] $SkipPackages,
    [switch] $SkipUpdates,
    [switch] $SkipWindowManager,
    [switch] $Yes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
$expectedRoot = [System.IO.Path]::GetFullPath((Join-Path $HOME '.config')).TrimEnd('\')

if ($repoRoot -ne $expectedRoot) {
    throw "This repository must be located at '$expectedRoot' (current: '$repoRoot')."
}

function Write-Section {
    param([Parameter(Mandatory)] [string] $Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Confirm-Step {
    param(
        [Parameter(Mandatory)] [string] $Title,
        [Parameter(Mandatory)] [string[]] $Details
    )

    Write-Section $Title
    foreach ($detail in $Details) {
        Write-Host "  - $detail"
    }

    if ($Yes) {
        Write-Host '  Approved by -Yes.' -ForegroundColor Green
        return $true
    }

    while ($true) {
        $response = (Read-Host 'Continue? [y/n]').Trim().ToLowerInvariant()
        switch ($response) {
            'y' { return $true }
            'yes' { return $true }
            'n' {
                Write-Host '  Skipped.' -ForegroundColor DarkYellow
                return $false
            }
            'no' {
                Write-Host '  Skipped.' -ForegroundColor DarkYellow
                return $false
            }
            default { Write-Host "Enter 'y' or 'n'." -ForegroundColor Yellow }
        }
    }
}
function Backup-Path {
    param([Parameter(Mandatory)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $backup = "$Path.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $Path -Destination $backup
    Write-Host "Backed up: $Path -> $backup"
}

function Test-LinkTarget {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Target
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -notin @('Junction', 'SymbolicLink')) {
        return $false
    }

    $actualTarget = [System.IO.Path]::GetFullPath([string] $item.Target).TrimEnd('\')
    $expectedTarget = [System.IO.Path]::GetFullPath($Target).TrimEnd('\')
    return $actualTarget -eq $expectedTarget
}

function New-ManagedLink {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Target,
        [Parameter(Mandatory)] [ValidateSet('Junction', 'SymbolicLink')] [string] $Type
    )

    if (Test-LinkTarget -Path $Path -Target $Target) {
        Write-Host "Already linked: $Path"
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    Backup-Path -Path $Path
    New-Item -ItemType $Type -Path $Path -Target $Target | Out-Null
    Write-Host "Linked: $Path -> $Target"
}

function Set-PowerShellProfileStub {
    $profilePath = Join-Path $HOME 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    $content = @'
$repoProfile = Join-Path $HOME '.config\powershell\Microsoft.PowerShell_profile.ps1'
if (Test-Path -LiteralPath $repoProfile) {
    . $repoProfile
}
'@

    if ((Test-Path -LiteralPath $profilePath) -and
        ((Get-Content -LiteralPath $profilePath -Raw).Trim() -eq $content.Trim())) {
        Write-Host "Already configured: $profilePath"
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profilePath) | Out-Null
    Backup-Path -Path $profilePath
    Set-Content -LiteralPath $profilePath -Value $content -Encoding utf8
    Write-Host "Created profile stub: $profilePath"
}

function Find-GitExecutable {
    $command = Get-Command git -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path $HOME 'scoop\shims\git.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd\git.exe'),
        (Join-Path $env:ProgramFiles 'Git\cmd\git.exe')
    )

    if (${env:ProgramFiles(x86)}) {
        $candidates += Join-Path ${env:ProgramFiles(x86)} 'Git\cmd\git.exe'
    }

    foreach ($keyPath in @(
        'HKCU:\SOFTWARE\GitForWindows',
        'HKLM:\SOFTWARE\GitForWindows',
        'HKLM:\SOFTWARE\WOW6432Node\GitForWindows'
    )) {
        $installPath = Get-ItemPropertyValue `
            -LiteralPath $keyPath `
            -Name InstallPath `
            -ErrorAction SilentlyContinue
        if ($installPath) {
            $candidates += Join-Path $installPath 'cmd\git.exe'
        }
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $gitDirectory = Split-Path -Parent $candidate
            if ($gitDirectory -notin ($env:PATH -split ';')) {
                $env:PATH = "$gitDirectory;$env:PATH"
            }
            return $candidate
        }
    }

    return $null
}

function Install-ScoopPackages {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing Scoop...'
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    }
    $gitExecutable = Find-GitExecutable
    if ($gitExecutable) {
        Write-Host "Using existing Git: $gitExecutable"
    } else {
        Write-Host 'Git was not found; installing it with Scoop...'
        scoop install git
        $gitExecutable = Find-GitExecutable
        if (-not $gitExecutable) {
            throw 'Git installation completed, but git.exe could not be resolved.'
        }
    }


    foreach ($bucket in @('extras', 'nerd-fonts')) {
        $bucketNames = @(scoop bucket list | ForEach-Object Name)
        if ($bucket -notin $bucketNames) {
            scoop bucket add $bucket
        }
    }

    $packages = @(
        'pwsh', 'psmux', 'starship', 'yazi', 'neovim', 'gh', 'lazygit',
        'ffmpeg', '7zip', 'jq', 'poppler', 'fd', 'ripgrep', 'fzf', 'zoxide',
        'resvg', 'imagemagick', 'tree-sitter', 'mingw', 'go', 'python',
        'btop', 'bat', 'eza', 'uv', 'csvlens', 'nodejs-lts',
        'JetBrainsMono-NF', 'D2Coding-NF', 'glazewm', 'zebar'
    )

    $installedPackages = @()
    try {
        $installedPackages = @(scoop list 6> $null | ForEach-Object Name)
    } catch {
        Write-Warning "Could not read the installed Scoop packages: $($_.Exception.Message)"
    }

    if (-not $SkipUpdates) {
        Write-Host 'Updating Scoop and its buckets...'
        $global:LASTEXITCODE = 0
        scoop update
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Scoop update failed with exit code $LASTEXITCODE."
        }
    }

    $failedPackages = [System.Collections.Generic.List[string]]::new()
    foreach ($package in $packages) {
        $isInstalled = $package -in $installedPackages
        if ($isInstalled -and $SkipUpdates) {
            Write-Host "Scoop package already installed: $package"
            continue
        }

        if ($isInstalled) {
            Write-Host "Updating Scoop package: $package"
        } else {
            Write-Host "Installing Scoop package: $package"
        }

        try {
            $global:LASTEXITCODE = 0
            if ($isInstalled) {
                scoop update $package
            } else {
                scoop install $package
            }
            if ($LASTEXITCODE -ne 0) {
                throw "Scoop exited with code $LASTEXITCODE."
            }
        } catch {
            $failedPackages.Add($package)
            Write-Warning "Skipped '$package': $($_.Exception.Message)"
            if ($isInstalled) {
                $global:LASTEXITCODE = 0
                scoop reset $package
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "Could not restore '$package' after the failed update."
                }
            }
        }
    }

    if (Get-Command leaf -ErrorAction SilentlyContinue) {
        Write-Host 'Leaf is already installed.'
    } elseif (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warning 'npm was not found; skipped Leaf installation.'
    } else {
        npm install --global '@rivolink/leaf'
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Leaf installation failed with exit code $LASTEXITCODE."
        }
    }

    if ($failedPackages.Count -gt 0) {
        Write-Warning "Failed Scoop packages: $($failedPackages -join ', ')"
    }
}

function Set-WindowManagerStartup {
    $configPath = Join-Path $repoRoot 'glazewm\config.yaml'
    $glazeWm = (Get-Command glazewm -ErrorAction Stop).Source
    $startupDir = [Environment]::GetFolderPath('Startup')
    $shortcutPath = Join-Path $startupDir 'GlazeWM.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $glazeWm
    $shortcut.Arguments = "start --config `"$configPath`""
    $shortcut.WorkingDirectory = Split-Path $configPath -Parent
    $shortcut.Save()
    Write-Host "Configured startup: $shortcutPath"
}

function Start-WindowManager {
    if (Get-Process glazewm -ErrorAction SilentlyContinue) {
        Write-Host 'GlazeWM is already running.'
        return
    }

    $configPath = Join-Path $repoRoot 'glazewm\config.yaml'
    $glazeWm = (Get-Command glazewm -ErrorAction Stop).Source
    Start-Process -FilePath $glazeWm -ArgumentList @('start', '--config', $configPath) -WindowStyle Hidden

    $deadline = (Get-Date).AddSeconds(20)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        try {
            $global:LASTEXITCODE = 0
            glazewm query monitors *> $null
        } catch {
            $global:LASTEXITCODE = 1
        }
        if ($LASTEXITCODE -eq 0) {
            Write-Host 'Started GlazeWM.'
            return
        }
    }

    Write-Warning 'GlazeWM did not answer its IPC within 20 seconds; start it manually.'
}

$localGitConfig = Join-Path $repoRoot 'git\.gitconfig'

if (-not $SkipPackages) {
    $packageDetails = @(
        'Install Scoop when it is missing.',
        'Reuse an existing Git installation, or install Git with Scoop when missing.',
        'Install the configured CLI tools, fonts, GlazeWM, and Zebar when missing.',
        'Update Scoop, its buckets, and every listed package that is already installed.',
        'Install Leaf globally with npm when it is missing.',
        'A failed package is reported and skipped; remaining packages continue.',
        'Pass -SkipUpdates to keep installed packages at their current version.'
    )
    if (Confirm-Step -Title 'Install packages' -Details $packageDetails) {
        try {
            Install-ScoopPackages
        } catch {
            Write-Warning "Package setup stopped: $($_.Exception.Message)"
        }
    }
}

$linkDetails = @(
    "Create junctions for Neovim, Leaf, and Zebar.",
    "Create symbolic links for Git and Windows Terminal settings.",
    "Create the PowerShell profile stub.",
    "Existing conflicting paths are moved to .backup.<timestamp>."
)
if (Confirm-Step -Title 'Create managed config links' -Details $linkDetails) {
    Write-Section 'Creating managed paths'
    New-ManagedLink -Type Junction -Path (Join-Path $env:LOCALAPPDATA 'nvim') -Target (Join-Path $repoRoot 'nvim')
    New-ManagedLink -Type Junction -Path (Join-Path $env:APPDATA 'leaf') -Target (Join-Path $repoRoot 'leaf')
    New-ManagedLink -Type Junction -Path (Join-Path $HOME '.glzr\zebar\window-dotfiles') -Target (Join-Path $repoRoot 'zebar')

    if (-not (Test-Path -LiteralPath $localGitConfig)) {
        Copy-Item (Join-Path $repoRoot 'git\.gitconfig.local.example') $localGitConfig
        Write-Host "Created local Git config: $localGitConfig"
    }
    New-ManagedLink -Type SymbolicLink -Path (Join-Path $HOME '.gitconfig') -Target $localGitConfig

    $terminalPackage = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe'
    if (Test-Path -LiteralPath $terminalPackage) {
        New-ManagedLink `
            -Type SymbolicLink `
            -Path (Join-Path $terminalPackage 'LocalState\settings.json') `
            -Target (Join-Path $repoRoot 'windows-terminal\settings.json')
    } else {
        Write-Warning 'Windows Terminal Stable was not found; skipped its settings link.'
    }

    Set-PowerShellProfileStub
}

$glazeConfig = Join-Path $repoRoot 'glazewm\config.yaml'
if (Confirm-Step -Title 'Configure user environment' -Details @(
    "Set GLAZEWM_CONFIG_PATH to $glazeConfig for this shell and future sessions."
)) {
    Write-Section 'Configuring environment'
    [Environment]::SetEnvironmentVariable('GLAZEWM_CONFIG_PATH', $glazeConfig, 'User')
    $env:GLAZEWM_CONFIG_PATH = $glazeConfig
}

if (-not $SkipWindowManager) {
    $startupPath = Join-Path ([Environment]::GetFolderPath('Startup')) 'GlazeWM.lnk'
    if (Confirm-Step -Title 'Configure GlazeWM startup' -Details @(
        "Create or update $startupPath.",
        "Start GlazeWM with $glazeConfig now and at every sign-in."
    )) {
        if (-not (Get-Command glazewm -ErrorAction SilentlyContinue)) {
            Write-Warning 'GlazeWM is not installed; skipped startup registration.'
        } else {
            Set-WindowManagerStartup
            Start-WindowManager
        }
    }
}

if (Get-Command ya -ErrorAction SilentlyContinue) {
    if (Confirm-Step -Title 'Install Yazi packages' -Details @(
        'Download and deploy packages declared in yazi/package.toml.'
    )) {
        Write-Section 'Installing Yazi packages'
        ya pkg install
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Yazi package installation failed with exit code $LASTEXITCODE."
        }
    }
}

Write-Section 'Setup complete'
Write-Host 'Restart PowerShell to load the profile.'
Write-Host "Edit Git identity in: $localGitConfig"
if (-not $SkipWindowManager) {
    Write-Host 'GlazeWM runs now and starts automatically at the next sign-in.'
}
