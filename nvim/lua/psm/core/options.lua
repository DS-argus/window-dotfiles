-- Python provider는 현재 설정에서 직접 쓰지 않으므로 꺼서 시작 속도를 줄인다.
vim.g.loaded_python3_provider = 0

local opt = vim.opt

-- 줄 번호는 절대/상대 번호를 같이 켜 두면 이동 단위 파악이 편하다.
opt.relativenumber = true
opt.number = true

-- 들여쓰기는 대부분의 JS/Python/Lua 프로젝트와 맞도록 2칸 기준으로 맞춘다.
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 긴 줄은 강제로 감지하기보다 가로 스크롤로 보는 편이 코드 읽기에 더 낫다.
opt.wrap = false

-- 기본 검색은 대소문자를 무시하되, 대문자가 포함되면 smartcase로 엄격하게 찾는다.
opt.ignorecase = true
opt.smartcase = true

-- 현재 줄 강조는 cursorline 하나만 켜 두면 시선 고정이 쉽다.
opt.cursorline = true

-- WezTerm + Nerd Font 조합을 전제로 true color와 안정적인 signcolumn을 사용한다.
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- 상태창/커맨드라인 표시는 모던 UI 플러그인과 겹치지 않도록 단순하게 둔다.
opt.laststatus = 3
opt.showmode = false
opt.cmdheight = 0

-- 파일 이동과 미리보기 경험을 부드럽게 만드는 자잘한 편의 옵션들이다.
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "split"
opt.mouse = "a"

-- 백스페이스는 일반 에디터처럼 자연스럽게 동작하게 풀어 둔다.
opt.backspace = "indent,eol,start"

-- Windows에서도 시스템 클립보드를 기본 레지스터로 바로 사용한다.
opt.clipboard:append("unnamedplus")

-- 분할창은 새 창이 현재 작업 흐름을 깨지 않도록 오른쪽/아래로 연다.
opt.splitright = true
opt.splitbelow = true

-- 임시 파일은 줄이고, 외부 변경 감지는 적극적으로 켠다.
opt.swapfile = false
opt.undofile = true
opt.autoread = true

local autoread_group = vim.api.nvim_create_augroup("PsmAutoread", { clear = true })

-- Git checkout, formatter, 외부 스크립트로 파일이 바뀐 경우 안전한 시점에 다시 읽는다.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
  group = autoread_group,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
