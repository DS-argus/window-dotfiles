# Windows Terminal이 Scoop 업데이트 전 PATH를 계속 상속할 수 있으므로,
# 레지스트리에 저장된 최신 PATH의 누락 항목을 현재 셸에 병합한다.
$registeredPathEntries = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';'
    [Environment]::GetEnvironmentVariable('Path', 'User') -split ';'
) | Where-Object { $_ } | ForEach-Object {
    [Environment]::ExpandEnvironmentVariables($_)
}

$env:PATH = @(
    @($env:PATH -split ';' | Where-Object { $_ })
    $registeredPathEntries
) | Select-Object -Unique | Join-String -Separator ';'

# starship, yazi가 repo 안의 설정 파일을 보도록 경로를 고정한다.
$env:STARSHIP_CONFIG = Join-Path $HOME '.config\starship\starship.toml'
$env:YAZI_CONFIG_HOME = Join-Path $HOME '.config\yazi'

# CLI 도구들이 외부 편집기를 요청할 때 Neovim을 사용한다.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:GIT_EDITOR = 'nvim'

if ($env:TERM -ne 'dumb') {
    try {
        Invoke-Expression (&starship init powershell)
    } catch {
        Write-Verbose 'starship is not available; using the default prompt.'
    }
}

# zoxide의 z, zi, 디렉터리 추적 훅을 PowerShell에 등록한다.
try {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} catch {
    Write-Verbose 'zoxide is not available; using the default cd behavior.'
}

# Yazi가 Windows에서 MIME 타입 판별에 사용할 file.exe를 지정한다.
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
