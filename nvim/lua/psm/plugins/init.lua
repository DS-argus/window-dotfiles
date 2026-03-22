-- lazy.nvim이 자동 스캔하는 대신, 여기서 실제로 쓰는 spec만 명시적으로 모은다.
-- 이렇게 해 두면 예전 실험 파일이 남아 있어도 현재 활성 설정과 분리된다.
local specs = {}

local modules = {
  "colorscheme",
  "snacks",
  "noice",
  "which-key",
  "smart-splits",
  "nvim-tree",
  "bufferline",
  "lualine",
  "colorize",
  "autopairs",
  "comment",
  "surround",
  "substitute",
  "treesitter",
  "nvim-ufo",
  "nvim-cmp",
  "formatting",
  "linting",
  "markdown",
  "lsp",
}

for _, name in ipairs(modules) do
  local mod = require("psm.plugins." .. name)

  -- 일부 파일은 단일 spec, 일부 파일은 여러 spec을 배열로 반환한다.
  -- 두 형태를 모두 받아들여 최종 플러그인 목록을 평탄화한다.
  if mod[1] and type(mod[1]) == "string" then
    table.insert(specs, mod)
  else
    vim.list_extend(specs, mod)
  end
end

return specs


