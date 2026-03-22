return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local languages = {
      "json",
      "yaml",
      "html",
      "css",
      "markdown",
      "markdown_inline",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
      "python",
      "rust",
    }

    local ok, treesitter = pcall(require, "nvim-treesitter")
    if not ok then
      return
    end

    treesitter.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- 새 nvim-treesitter는 설치 관리만 담당하고, highlight는 Neovim 기본 TS 엔진이 맡는다.
    -- parser가 비어 있을 때만 설치를 시도하고, CLI가 없으면 조용히 넘긴다.
    local installed = {}
    for _, lang in ipairs(treesitter.get_installed("parsers")) do
      installed[lang] = true
    end

    local missing = {}
    for _, lang in ipairs(languages) do
      if not installed[lang] then
        table.insert(missing, lang)
      end
    end

    local has_compiler = vim.fn.executable("clang") == 1
      or vim.fn.executable("gcc") == 1
      or vim.fn.executable("zig") == 1
      or vim.fn.executable("cl") == 1

    if #missing > 0 and vim.fn.executable("tree-sitter") == 1 and has_compiler then
      treesitter.install(missing)
    end

    local group = vim.api.nvim_create_augroup("PsmTreesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    local ok_autotag, autotag = pcall(require, "nvim-ts-autotag")
    if ok_autotag then
      autotag.setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end
  end,
}
