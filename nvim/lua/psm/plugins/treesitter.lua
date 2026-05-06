return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local function resolve_executable(candidates)
      for _, candidate in ipairs(candidates) do
        if candidate and candidate ~= "" then
          if vim.uv.fs_stat(candidate) then
            return candidate
          end

          local exepath = vim.fn.exepath(candidate)
          if exepath ~= "" then
            return exepath
          end
        end
      end
    end

    local home = vim.env.USERPROFILE or vim.env.HOME or ""
    local scoop_apps = home ~= "" and vim.fs.joinpath(home, "scoop", "apps") or nil
    local gcc_path = scoop_apps and vim.fs.joinpath(scoop_apps, "mingw", "current", "bin", "gcc.exe") or nil
    local clang_path = scoop_apps and vim.fs.joinpath(scoop_apps, "llvm", "current", "bin", "clang.exe") or nil

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

    local ok, treesitter = pcall(require, "nvim-treesitter.configs")
    if not ok then
      return
    end

    local ok_install, install = pcall(require, "nvim-treesitter.install")
    if not ok_install then
      return
    end

    install.compilers = vim.tbl_filter(function(path)
      return path and path ~= ""
    end, {
      resolve_executable({ gcc_path, "gcc" }),
      resolve_executable({ clang_path, "clang" }),
      resolve_executable({ "cl" }),
      resolve_executable({ "zig" }),
    })

    local has_compiler = #install.compilers > 0

    -- Neovim 0.11에서는 안정적인 구버전 API(branch=master)를 고정해서 사용한다.
    -- 컴파일러가 없으면 parser 자동 설치를 건너뛰고, Python은 regex 하이라이트를 함께 켠다.
    treesitter.setup({
      ensure_installed = has_compiler and languages or {},
      sync_install = false,
      auto_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "python" },
      },
      indent = {
        enable = true,
        disable = { "python" },
      },
      autotag = {
        enable = true,
      },
    })

    vim.cmd("syntax enable")
  end,
}
