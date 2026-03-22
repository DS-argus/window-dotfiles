#### 실제 powershell 7+ config 파일인  ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1에 다음이 있어야 함
# $repoProfile = Join-Path $HOME '.config\powershell\Microsoft.PowerShell_profile.ps1'
# if (Test-Path -LiteralPath $repoProfile) {
#     . $repoProfile
# }

$profileRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$profileParts = @(
    'cli-init.ps1',
    'aliases.ps1'
)

foreach ($part in $profileParts) {
    $path = Join-Path $profileRoot $part

    if (Test-Path -LiteralPath $path) {
        . $path
    }
}
