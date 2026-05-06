-- Python은 전역 2칸 설정과 분리해 4칸 들여쓰기를 고정한다.
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

-- 포매터 폭 기준은 유지하되 화면 세로 가이드는 띄우지 않는다.
vim.opt_local.textwidth = 88
vim.opt_local.colorcolumn = ""
