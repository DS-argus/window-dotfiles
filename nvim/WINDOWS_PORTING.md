# Neovim Windows 메모

## 현재 방향

- Windows용 `nvim/`은 이제 macOS 설정의 단순 복제보다 `snacks.nvim` 중심 구조를 우선한다.
- 파일 탐색, picker, dashboard, notifier, terminal, zen, scratch, words 이동은 `snacks.nvim`으로 통일했다.
- 키 힌트는 `which-key.nvim`을 별도로 유지해 `leader` 이후 가능한 키를 계속 보여준다.
- LSP, 자동완성, 포맷팅, 린팅은 Snacks 바깥의 전용 플러그인으로 유지한다.

## 메모

- 첫 실행에서는 lazy.nvim이 플러그인을 설치하므로, 이상하면 `nvim`을 한 번 더 열어 확인한다.
- `LuaSnip`의 `jsregexp`는 여전히 native build 없이 사용한다.
- `snacks.nvim`은 공식 README 예시 키맵을 기준으로 현재 설정에 맞게 한국어 설명으로 재배치했다.
