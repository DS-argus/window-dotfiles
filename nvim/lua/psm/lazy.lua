-- lazy.nvim은 플러그인 설치/업데이트를 담당하는 부트스트랩 레이어다.
-- 아직 설치되지 않은 첫 실행에서도 자동으로 clone 되도록 먼저 경로를 준비한다.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("psm.plugins"), {
  -- 첫 설치 시 색 테마가 비어 보이지 않도록 기본 테마를 미리 지정한다.
  install = {
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  ui = {
    border = "rounded",
  },
})
