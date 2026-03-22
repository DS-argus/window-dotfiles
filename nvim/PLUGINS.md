# Neovim Plugin Overview

- 기준: `lua/psm/plugins/*.lua`, `lua/psm/plugins/lsp/init.lua`
- 의존성 그래프 기준: `lazy.nvim` spec의 direct dependency

## 전체 관계

```text
graph TD
  lazy["lazy.nvim"]

  subgraph snacks_group["Snacks 제공"]
    snacks["folke/snacks.nvim"]
  end

  subgraph ui_group["UI / 탐색"]
    tokyonight["folke/tokyonight.nvim"]
    noice["folke/noice.nvim"]
    whichkey["folke/which-key.nvim"]
    nvimtree["nvim-tree/nvim-tree.lua"]
    bufferline["akinsho/bufferline.nvim"]
    lualine["nvim-lualine/lualine.nvim"]
    colorizer["catgoose/nvim-colorizer.lua"]
  end

  subgraph edit_group["편집 보조"]
    autopairs["windwp/nvim-autopairs"]
    comment["numToStr/Comment.nvim"]
    surround["kylechui/nvim-surround"]
    substitute["gbprod/substitute.nvim"]
    treesitter["nvim-treesitter/nvim-treesitter"]
    ufo["kevinhwang91/nvim-ufo"]
  end

  subgraph code_group["코드 / LSP"]
    cmp["hrsh7th/nvim-cmp"]
    conform["stevearc/conform.nvim"]
    lint["mfussenegger/nvim-lint"]
    lazydev["folke/lazydev.nvim"]
    mason["williamboman/mason.nvim"]
    lspconfig["neovim/nvim-lspconfig"]
  end

  subgraph markdown_group["Markdown"]
    rendermd["MeanderingProgrammer/render-markdown.nvim"]
  end

  subgraph dep_group["보조 의존성"]
    devicons["nvim-tree/nvim-web-devicons"]
    nui["MunifTanjim/nui.nvim"]
    notify["rcarriga/nvim-notify"]
    tscontext["JoosepAlviste/nvim-ts-context-commentstring"]
    autotag["windwp/nvim-ts-autotag"]
    promise["kevinhwang91/promise-async"]
    cmpbuffer["hrsh7th/cmp-buffer"]
    cmppath["hrsh7th/cmp-path"]
    luasnip["L3MON4D3/LuaSnip"]
    cmpluasnip["saadparwaiz1/cmp_luasnip"]
    lspkind["onsails/lspkind.nvim"]
    friendly["rafamadriz/friendly-snippets"]
    masonlsp["williamboman/mason-lspconfig.nvim"]
    masontools["WhoIsSethDaniel/mason-tool-installer.nvim"]
    cmpnvimlsp["hrsh7th/cmp-nvim-lsp"]
  end

  lazy --> snacks
  lazy --> tokyonight
  lazy --> noice
  lazy --> whichkey
  lazy --> nvimtree
  lazy --> bufferline
  lazy --> lualine
  lazy --> colorizer
  lazy --> autopairs
  lazy --> comment
  lazy --> surround
  lazy --> substitute
  lazy --> treesitter
  lazy --> ufo
  lazy --> cmp
  lazy --> conform
  lazy --> lint
  lazy --> rendermd
  lazy --> lazydev
  lazy --> mason
  lazy --> lspconfig

  snacks --> devicons
  noice --> nui
  noice --> notify
  nvimtree --> devicons
  bufferline --> devicons
  lualine --> devicons
  autopairs --> cmp
  comment --> tscontext
  treesitter --> autotag
  ufo --> promise
  cmp --> cmpbuffer
  cmp --> cmppath
  cmp --> luasnip
  cmp --> cmpluasnip
  cmp --> lspkind
  cmp --> friendly
  rendermd --> treesitter
  rendermd --> devicons
  mason --> masonlsp
  mason --> masontools
  lspconfig --> cmpnvimlsp
```

## Snacks 제공

### `folke/snacks.nvim`

#### 설명

- 검색, picker, Git 보조, 터미널, scratch, zen 통합 UX

#### 특징

- 활성 기능: `picker`, `dashboard`, `explorer`, `terminal`, `lazygit`, `gitbrowse`, `scratch`, `zen`, `words`, `indent`, `scope`, `scroll`, `statuscolumn`, `bigfile`, `quickfile`, `dim`
- `notifier` 비활성화
- LSP 탐색 UI 통합

#### 단축키

- 검색: `<leader><space>`, `<leader>ff`, `<leader>fg`, `<leader>fr`, `<leader>/`, `<leader>sg`, `<leader>sw`
- 탐색: `gd`, `gD`, `gr`, `gI`, `gy`, `<leader>ss`, `<leader>sS`
- Git: `<leader>gg`, `<leader>gs`, `<leader>gl`, `<leader>gL`, `<leader>gf`, `<leader>gb`
- 작업: `<leader>es`, `<leader>tt`, `<C-/>`, `<leader>tz`, `<leader>tZ`, `<leader>.`, `<leader>S`, `<leader>bd`, `<leader>cR`
- 토글: `<leader>us`, `<leader>uw`, `<leader>ul`, `<leader>uL`, `<leader>ud`, `<leader>uc`, `<leader>uT`, `<leader>ub`, `<leader>ug`, `<leader>uD`, `<leader>uh`
- 참조 점프: `[[`, `]]`

#### 의존성

```text
graph LR
  snacks["folke/snacks.nvim"] --> devicons["nvim-tree/nvim-web-devicons"]
```

## 그 외 플러그인

### `folke/tokyonight.nvim`

#### 설명

- 기본 컬러스킴

#### 특징

- `night` 스타일 기반
- 투명 배경 중심 커스텀 색상
- UI 플러그인보다 먼저 적용

#### 단축키

- 없음

#### 의존성

```text
graph LR
  tokyonight["folke/tokyonight.nvim"]
```

### `folke/noice.nvim`

#### 설명

- cmdline, message, popupmenu, LSP 문서 표시 UI

#### 특징

- 중앙 팝업 cmdline
- 긴 메시지 split 출력
- `vim.notify` 파이프라인 통합
- hover, signature help, markdown 렌더링 강화

#### 단축키

- `<leader>nd`, `<leader>nh`, `<leader>nl`

#### 의존성

```text
graph LR
  noice["folke/noice.nvim"] --> nui["MunifTanjim/nui.nvim"]
  noice --> notify["rcarriga/nvim-notify"]
```

### `folke/which-key.nvim`

#### 설명

- 키맵 힌트 UI

#### 특징

- `modern` preset 사용
- `<leader>` 그룹 구조 표시
- Snacks 중심 키맵 탐색 보조

#### 단축키

- 자동 표시

#### 의존성

```text
graph LR
  whichkey["folke/which-key.nvim"]
```

### `nvim-tree/nvim-tree.lua`

#### 설명

- 메인 파일 탐색기

#### 특징

- 현재 파일 기준 root, cwd 동기화
- Git 상태, diagnostics 동시 표시
- 트리 내부 홈로우 이동 구성
- `Snacks.explorer`와 별개로 메인 트리 역할

#### 단축키

- 전역: `<leader>ee`, `<leader>ef`, `<leader>ec`, `<leader>er`
- 트리 내부: `?`, `h`, `l`, `v`, `s`

#### 의존성

```text
graph LR
  nvimtree["nvim-tree/nvim-tree.lua"] --> devicons_tree["nvim-tree/nvim-web-devicons"]
```

### `akinsho/bufferline.nvim`

#### 설명

- 상단 버퍼 라인

#### 특징

- 열린 버퍼 목록 표시
- LSP diagnostics 표시
- close 아이콘 제거

#### 단축키

- `<Tab>`, `<S-Tab>`

#### 의존성

```text
graph LR
  bufferline["akinsho/bufferline.nvim"] --> devicons_buffer["nvim-tree/nvim-web-devicons"]
```

### `nvim-lualine/lualine.nvim`

#### 설명

- 상태줄

#### 특징

- 파일 경로 표시
- 인코딩, 파일 포맷, 파일 타입 표시
- `lazy.nvim` 업데이트 수 표시
- 커스텀 테마 사용

#### 단축키

- 없음

#### 의존성

```text
graph LR
  lualine["nvim-lualine/lualine.nvim"] --> devicons_lualine["nvim-tree/nvim-web-devicons"]
```

### `catgoose/nvim-colorizer.lua`

#### 설명

- 색상 코드 미리보기

#### 특징

- 모든 파일 타입 대상
- HEX, CSS 계열 색상 확인에 유용

#### 단축키

- 없음

#### 의존성

```text
graph LR
  colorizer["catgoose/nvim-colorizer.lua"]
```

### `windwp/nvim-autopairs`

#### 설명

- 괄호, 따옴표 자동 닫기

#### 특징

- Treesitter 문맥 인식
- `nvim-cmp` confirm 동작 연동

#### 단축키

- 자동 동작

#### 의존성

```text
graph LR
  autopairs["windwp/nvim-autopairs"] --> cmp_dep["hrsh7th/nvim-cmp"]
```

### `numToStr/Comment.nvim`

#### 설명

- 주석 토글

#### 특징

- JSX, TSX, HTML 문맥별 주석 처리
- 기본 키맵 유지

#### 단축키

- 기본값: `gc`, `gb`

#### 의존성

```text
graph LR
  comment["numToStr/Comment.nvim"] --> tscontext["JoosepAlviste/nvim-ts-context-commentstring"]
```

### `kylechui/nvim-surround`

#### 설명

- surround 추가, 변경, 삭제

#### 특징

- 괄호, 따옴표, 태그 편집 흐름 단축
- 기본 키맵 유지

#### 단축키

- 기본값: `ys`, `cs`, `ds`

#### 의존성

```text
graph LR
  surround["kylechui/nvim-surround"]
```

### `gbprod/substitute.nvim`

#### 설명

- 모션 기반 치환

#### 특징

- `s` 계열 키 재구성
- 삭제보다 치환 중심 편집 흐름

#### 단축키

- `s`, `ss`, `S`, 비주얼 `s`

#### 의존성

```text
graph LR
  substitute["gbprod/substitute.nvim"]
```

### `nvim-treesitter/nvim-treesitter`

#### 설명

- 구문 하이라이트, 구조 기반 편집 중심축

#### 특징

- highlight, indent 활성화
- incremental selection 활성화
- `nvim-ts-autotag` 연동
- `json`, `yaml`, `html`, `css`, `markdown`, `bash`, `lua`, `python`, `rust` 등 parser 설치 대상 지정

#### 단축키

- `<C-Space>`, `<BS>`

#### 의존성

```text
graph LR
  treesitter["nvim-treesitter/nvim-treesitter"] --> autotag["windwp/nvim-ts-autotag"]
```

### `kevinhwang91/nvim-ufo`

#### 설명

- fold UX 강화

#### 특징

- Treesitter 우선 folding
- 불가 시 indent 기반 fallback
- foldcolumn, fold 아이콘, 초기 fold level 정리

#### 단축키

- `zR`, `zM`

#### 의존성

```text
graph LR
  ufo["kevinhwang91/nvim-ufo"] --> promise["kevinhwang91/promise-async"]
```

### `hrsh7th/nvim-cmp`

#### 설명

- 자동완성 엔진

#### 특징

- LSP, buffer, path, snippet 소스 사용
- `LuaSnip`, `friendly-snippets` 기반 스니펫 확장
- `lspkind.nvim` 기반 아이콘 표시
- 문서 스크롤, 항목 이동, confirm 키 직접 지정

#### 단축키

- 삽입 모드: `<C-j>`, `<C-k>`, `<C-b>`, `<C-f>`, `<C-Space>`, `<C-e>`, `<CR>`

#### 의존성

```text
graph LR
  cmp["hrsh7th/nvim-cmp"] --> cmpbuffer["hrsh7th/cmp-buffer"]
  cmp --> cmppath["hrsh7th/cmp-path"]
  cmp --> luasnip["L3MON4D3/LuaSnip"]
  cmp --> cmpluasnip["saadparwaiz1/cmp_luasnip"]
  cmp --> lspkind["onsails/lspkind.nvim"]
  cmp --> friendly["rafamadriz/friendly-snippets"]
```

### `stevearc/conform.nvim`

#### 설명

- 포맷터 관리

#### 특징

- 저장 후 자동 포맷
- LSP 포맷 fallback 사용
- `prettier`, `stylua`, `ruff_organize_imports`, `ruff_format` 조합

#### 단축키

- `<leader>cf`

#### 의존성

```text
graph LR
  conform["stevearc/conform.nvim"]
```

### `mfussenegger/nvim-lint`

#### 설명

- 린터 실행

#### 특징

- Python 기준 `ruff` 사용
- lint on/off 토글 제공

#### 단축키

- `<leader>lt`, `<leader>l`

#### 의존성

```text
graph LR
  lint["mfussenegger/nvim-lint"]
```

### `MeanderingProgrammer/render-markdown.nvim`

#### 설명

- Markdown 렌더링

#### 특징

- `obsidian` preset 사용
- Markdown 파일에서만 로드
- 기본 상태 raw text
- 헤더, 체크박스, 강조 구문 가독성 개선

#### 단축키

- Markdown 버퍼: `<leader>mr`

#### 의존성

```text
graph LR
  rendermd["MeanderingProgrammer/render-markdown.nvim"] --> treesitter_md["nvim-treesitter/nvim-treesitter"]
  rendermd --> devicons_md["nvim-tree/nvim-web-devicons"]
```

### `folke/lazydev.nvim`

#### 설명

- Lua 개발 보조

#### 특징

- `lua_ls`의 Neovim runtime 이해도 보강
- `vim.uv` 라이브러리 인식 보조
- Lua 파일 한정 로드

#### 단축키

- 없음

#### 의존성

```text
graph LR
  lazydev["folke/lazydev.nvim"]
```

### `williamboman/mason.nvim`

#### 설명

- LSP 서버, 외부 CLI 도구 설치 관리

#### 특징

- 서버 설치와 도구 설치 분리 관리
- 현재 대상: `pyright`, `lua_ls`, `rust_analyzer`, `ruff`, `stylua`, `prettier`

#### 단축키

- `:Mason`, `:MasonInstall`, `:MasonUpdate`

#### 의존성

```text
graph LR
  mason["williamboman/mason.nvim"] --> masonlsp["williamboman/mason-lspconfig.nvim"]
  mason --> masontools["WhoIsSethDaniel/mason-tool-installer.nvim"]
```

### `neovim/nvim-lspconfig`

#### 설명

- LSP 서버 연결 레이어

#### 특징

- 활성 서버: `lua_ls`, `pyright`, `rust_analyzer`
- diagnostics 스타일 통일
- hover, rename, code action, diagnostics 이동 중심 키맵 구성
- 정의, 참조, 구현 탐색 일부를 Snacks picker로 위임

#### 단축키

- `K`, `gK`, `<leader>ca`, `<leader>cr`, `<leader>cd`, `[d`, `]d`

#### 의존성

```text
graph LR
  lspconfig["neovim/nvim-lspconfig"] --> cmpnvimlsp["hrsh7th/cmp-nvim-lsp"]
```

## 참고

- 플러그인 매니저: `lazy.nvim`
- 공통 창 이동, 탭 관리 키맵: `lua/psm/core/keymaps.lua`
- Markdown 버퍼 Mermaid 프리뷰 키: `<leader>mt`, `<leader>md`

