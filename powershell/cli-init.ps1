# starship, yazi가 repo 안의 설정 파일을 보도록 경로를 고정한다.
$env:STARSHIP_CONFIG = Join-Path $HOME '.config\starship\starship.toml'
$env:YAZI_CONFIG_HOME = Join-Path $HOME '.config\yazi'

# starship 프롬프트를 초기화한다.
try {
    Invoke-Expression (&starship init powershell)
} catch {
    Write-Verbose 'starship is not available; using the default prompt.'
}

# WezTerm이 현재 디렉터리를 추적할 수 있도록 OSC 7 시퀀스를 보내기 -> 새 pane/tab도 현재 폴더에서 열기 위해서
function global:Write-WeztermOsc7 {
    if ($env:TERM_PROGRAM -ne 'WezTerm') {
        return
    }

    $currentLocation = $executionContext.SessionState.Path.CurrentLocation
    if ($currentLocation.Provider.Name -ne 'FileSystem') {
        return
    }

    $ansiEscape = [char]27
    $providerPath = $currentLocation.ProviderPath -replace "\\", "/"
    $osc7 = "$ansiEscape]7;file://${env:COMPUTERNAME}/${providerPath}$ansiEscape\"
    $Host.UI.Write($osc7)
}

# starship이 프롬프트를 그리기 직전에 WezTerm 동기화를 실행
function global:Invoke-Starship-PreCommand {
    Write-WeztermOsc7
}

# zoxide의 z, zi, 디렉터리 추적 훅을 PowerShell에 등록한다.
try {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} catch {
    Write-Verbose 'zoxide is not available; using the default cd behavior.'
}

# Yazi 실행 시 필요한 file.exe 경로를 한 번만 찾아서 환경 변수로 잡는다.
function global:Initialize-YaziEnvironment {
    if ($script:YaziEnvironmentInitialized) {
        return
    }

    $fileOneCandidates = @(
        (Join-Path $HOME 'scoop\apps\git\current\usr\bin\file.exe'),
        'C:\Program Files\Git\usr\bin\file.exe'
    )

    foreach ($candidate in $fileOneCandidates) {
        if (Test-Path -LiteralPath $candidate) {
            $env:YAZI_FILE_ONE = $candidate
            break
        }
    }

    $script:YaziEnvironmentInitialized = $true
}
