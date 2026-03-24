# Powershell 용 alias를 등록하는 스크립트

Remove-Item alias:cd -ErrorAction SilentlyContinue
Remove-Item alias:ls -ErrorAction SilentlyContinue

# zoxide를 기본 cd로 변경
function global:cd {
    z @args
}

# yazi, y 등록
function global:yazi {
    Initialize-YaziEnvironment
    & yazi.exe @args
}

function global:y {
    Initialize-YaziEnvironment
    $tmp = (New-TemporaryFile).FullName

    try {
        & yazi.exe @args --cwd-file="$tmp"
        $cwd = Get-Content -LiteralPath $tmp -Encoding UTF8 -ErrorAction SilentlyContinue

        if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
            Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
        }
    } finally {
        if (Test-Path -LiteralPath $tmp) {
            Remove-Item -LiteralPath $tmp -Force
        }
    }
}

# eza로 ls 대체
function global:ls {
    eza --icons=always @args
}

function global:ll {
    eza -lah --icons=always @args
}

function global:la {
    eza -a --icons=always @args
}

function global:lt {
    eza -aT -L1 --color=always --group-directories-first --icons @args
}

function global:lt2 {
    eza -aT -L2 --color=always --group-directories-first --icons @args
}

function global:lt3 {
    eza -aT -L3 --color=always --group-directories-first --icons @args
}

# codex는 기본적으로 inline 모드로 실행하고, 추가 옵션은 그대로 전달
$script:CodexCommand = (Get-Command codex -CommandType ExternalScript,Application | Select-Object -First 1).Source
function global:codex {
    & $script:CodexCommand --no-alt-screen @args
}

function global:lg {
    lazygit @args
}

# c 로 clear, e로 exit
function global:c {
    Clear-Host
}

function global:e {
    exit
}
