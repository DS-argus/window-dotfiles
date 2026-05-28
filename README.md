# Windows CLI 설정

이 저장소는 Windows CLI 환경의 원본 설정입니다.

저장소 위치는 고정합니다.

```powershell
$HOME\.config
```

링크 정책은 단순하게 가져갑니다.

- 기본 실행 경로가 폴더이면 `Junction`으로 연결합니다.
- 기본 실행 경로가 단일 파일이면 `SymbolicLink`로 연결합니다.
- 앱이 `~\.config`를 기본 경로로 직접 읽으면 별도 링크를 만들지 않습니다.
- 환경변수로 설정 경로를 지정하는 편이 더 명확한 앱은 PowerShell 프로필에서 저장소 경로를 고정합니다.

이 방식이면 저장소 안의 파일을 수정하는 것이 곧 실제 실행 설정 수정이 됩니다.

## 구성

- 터미널 에뮬레이터: `Alacritty` 또는 `WezTerm`
- 터미널 멀티플렉서: `psmux`
- 셸: `PowerShell 7`
- 파일 관리자: `Yazi`
- 에디터: `Neovim`
- 프롬프트: `Starship`
- Git 도구: `git`, `lazygit`, `gh`, `gh-dash`
- CLI 도구: `eza`, `bat`, `btop`, `fzf`, `zoxide`, `ripgrep`, `fd`, `uv`, `csvlens`

터미널 에뮬레이터는 창을 띄우는 호스트 역할만 맡기고, 탭/패널/세션/상태줄/복원은 `psmux`가 담당합니다.

## 터미널 선택

### Alacritty

`Alacritty`는 빠르고 단순한 터미널입니다. 설정 표면이 작고 예측 가능해서 `psmux` 위주의 환경과 잘 맞습니다.

현재 저장소의 [alacritty/alacritty.toml](alacritty/alacritty.toml)은 PowerShell 7을 실행하고, 창/폰트/커서 같은 최소 설정만 관리합니다. Alacritty 자체의 탭이나 패널 기능은 쓰지 않고 `psmux`에 맡기는 구성을 전제로 합니다.

### WezTerm

`WezTerm`은 기능이 더 많은 터미널입니다. 대체 폰트, 키 바인딩, 렌더링, 플랫폼별 동작을 세밀하게 조정하기 좋습니다.

현재 저장소의 [wezterm/wezterm.lua](wezterm/wezterm.lua)는 WezTerm의 내장 탭/패널/워크스페이스 기능을 끄고, 클립보드와 폰트 크기 조절 같은 최소 키만 남깁니다. 마찬가지로 멀티플렉싱은 `psmux`가 담당합니다.

둘 중 하나만 써도 되고, 둘 다 설치해 두고 상황에 따라 골라도 됩니다.

## 설치

먼저 Git을 설치한 뒤 저장소를 clone합니다.

```powershell
git clone <repo-url> "$HOME\.config"
Set-Location "$HOME\.config"
```

Scoop과 필요한 bucket을 준비합니다.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop bucket add extras
scoop bucket add nerd-fonts
```

필수 도구를 설치합니다.

```powershell
scoop install `
  pwsh psmux starship yazi neovim `
  git gh lazygit `
  ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick `
  btop bat eza uv csvlens nodejs-lts `
  JetBrainsMono-NF D2Coding-NF
```

터미널 에뮬레이터는 원하는 것을 설치합니다.

```powershell
# 둘 다 설치해도 됩니다.
scoop install alacritty wezterm
```

## 링크 생성

아래 명령은 기존 파일/폴더가 있으면 시간값이 붙은 백업 경로로 이동한 뒤 링크를 만듭니다. 기존 경로가 이미 링크라면 제거하고 다시 만듭니다.

```powershell
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

# 폴더 설정: Junction.
New-DotfileJunction "$env:LOCALAPPDATA\nvim" "$HOME\.config\nvim"
New-DotfileJunction "$env:APPDATA\alacritty" "$HOME\.config\alacritty"

# 단일 파일 설정: SymbolicLink.
New-DotfileSymlink "$HOME\.gitconfig" "$HOME\.config\git\.gitconfig"
New-DotfileSymlink "$HOME\.wezterm.lua" "$HOME\.config\wezterm\wezterm.lua"
New-DotfileSymlink "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "$HOME\.config\powershell\Microsoft.PowerShell_profile.ps1"
```

`SymbolicLink` 생성은 Windows 개발자 모드 또는 관리자 권한 PowerShell이 필요할 수 있습니다. `Junction`은 보통 일반 권한으로 동작합니다.

## psmux

`psmux`는 `~\.config\psmux\psmux.conf`를 기본 경로로 직접 읽습니다. 그래서 별도 링크가 필요 없습니다.

플러그인은 저장소가 아니라 `~\.psmux\plugins` 아래에 설치합니다.

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.psmux\plugins" | Out-Null

Remove-Item "$env:TEMP\psmux-plugins" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$HOME\.psmux\plugins\ppm" -Recurse -Force -ErrorAction SilentlyContinue

git clone https://github.com/psmux/psmux-plugins.git "$env:TEMP\psmux-plugins"
Copy-Item "$env:TEMP\psmux-plugins\ppm" "$HOME\.psmux\plugins\ppm" -Recurse -Force
Remove-Item "$env:TEMP\psmux-plugins" -Recurse -Force

pwsh -NoProfile -ExecutionPolicy Bypass -File "$HOME\.psmux\plugins\ppm\scripts\install_plugins.ps1"
```

실행은 터미널에서 `psmux`를 입력하면 됩니다.

## PowerShell

PowerShell 7의 기본 프로필 파일은 심볼릭 링크로 저장소의 [powershell/Microsoft.PowerShell_profile.ps1](powershell/Microsoft.PowerShell_profile.ps1)을 가리킵니다.

이 프로필은 다음을 처리합니다.

- `aliases.ps1`, `cli-init.ps1` 로드
- `starship` 초기화
- `zoxide` 초기화
- `Yazi` wrapper 함수 등록
- `STARSHIP_CONFIG`, `YAZI_CONFIG_HOME` 환경변수 설정

`WindowsPowerShell` 5.1은 대상이 아닙니다. 기본 셸은 `pwsh`를 사용합니다.

## Yazi

Yazi 설정은 [yazi/](yazi/)에 있습니다.

PowerShell 프로필에서 아래 환경변수를 설정해 Yazi가 저장소 설정을 읽게 합니다.

```powershell
$env:YAZI_CONFIG_HOME = Join-Path $HOME '.config\yazi'
```

패키지는 한 번 설치합니다.

```powershell
ya pkg install
```

`y` 함수는 Yazi를 실행한 뒤, 종료 시 Yazi의 마지막 디렉터리로 현재 shell 위치를 이동합니다.

## Starship

Starship 설정은 [starship/starship.toml](starship/starship.toml)에 있습니다.

PowerShell 프로필에서 아래 환경변수를 설정합니다.

```powershell
$env:STARSHIP_CONFIG = Join-Path $HOME '.config\starship\starship.toml'
```

## Git

`~\.gitconfig`는 [git/.gitconfig](git/.gitconfig)를 가리키는 심볼릭 링크입니다.

개인 이름과 이메일은 git에 올리지 않는 로컬 파일에 둡니다.

```powershell
Copy-Item "$HOME\.config\git\.gitconfig.local.example" "$HOME\.config\git\.gitconfig.local"
nvim "$HOME\.config\git\.gitconfig.local"
```

## GitHub CLI

GitHub CLI 인증과 `gh-dash` 설치:

```powershell
gh auth login
gh extension install dlvhdr/gh-dash
```

`gh-dash`는 [gh-dash/config.yml](gh-dash/config.yml)을 기본 경로에서 직접 읽습니다.

## Neovim

`%LOCALAPPDATA%\nvim`은 [nvim/](nvim/)으로 연결된 Junction입니다. Neovim 데이터는 `%LOCALAPPDATA%\nvim-data`에 남겨 둡니다.

첫 실행 후 플러그인과 도구를 설치합니다.

```vim
:Lazy sync
:MasonInstall lua-language-server pyright rust-analyzer ruff stylua prettier
```

## 관리 경로

| Repo 경로 | 런타임 경로 | 방식 |
| --- | --- | --- |
| `alacritty/` | `%APPDATA%\alacritty` | Junction |
| `nvim/` | `%LOCALAPPDATA%\nvim` | Junction |
| `git/.gitconfig` | `%USERPROFILE%\.gitconfig` | SymbolicLink |
| `powershell/Microsoft.PowerShell_profile.ps1` | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | SymbolicLink |
| `wezterm/wezterm.lua` | `%USERPROFILE%\.wezterm.lua` | SymbolicLink |
| `psmux/psmux.conf` | `%USERPROFILE%\.config\psmux\psmux.conf` | 기본 경로 |
| `scoop/config.json` | `%USERPROFILE%\.config\scoop\config.json` | 기본 경로 |
| `gh-dash/config.yml` | `%USERPROFILE%\.config\gh-dash\config.yml` | 기본 경로 |
| `starship/starship.toml` | `STARSHIP_CONFIG` | 환경변수 |
| `yazi/` | `YAZI_CONFIG_HOME` | 환경변수 |

## 메모

- 이 저장소는 `$HOME\.config`에 clone되어 있다고 가정합니다.
- 실행 중 생기는 상태 파일은 저장소에 넣지 않습니다. 예: `%LOCALAPPDATA%\nvim-data`, `%APPDATA%\yazi\state`, `~\.psmux`.
- `git\.gitconfig.local`은 개인 정보 파일이므로 git에서 무시합니다.
- Alacritty와 WezTerm 중 어느 쪽을 쓰든, 패널/창/세션 관리는 `psmux`가 담당합니다.
