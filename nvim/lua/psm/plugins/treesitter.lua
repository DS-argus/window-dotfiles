return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
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
      "go",
      "python",
      "rust",
    }

    local ok, treesitter = pcall(require, "nvim-treesitter")
    if not ok then
      return
    end

    local compilers = vim.tbl_filter(function(path)
      return path and path ~= ""
    end, {
      resolve_executable({ gcc_path, "gcc" }),
      resolve_executable({ clang_path, "clang" }),
      resolve_executable({ "cl" }),
      resolve_executable({ "zig" }),
    })

    local has_compiler = #compilers > 0

    if has_compiler then
      vim.env.CC = compilers[1]
    end

    treesitter.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    if has_compiler and vim.fn.executable("tree-sitter") == 1 then
      local installed = {}

      for _, lang in ipairs(treesitter.get_installed()) do
        installed[lang] = true
      end

      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, languages)

      for _, lang in ipairs(missing) do
        treesitter.install({ lang }):wait(300000)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)

        if lang and vim.tbl_contains(languages, lang) then
          pcall(vim.treesitter.start, args.buf, lang)
        end

        if lang and lang ~= "python" and vim.tbl_contains(languages, lang) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
      desc = "Enable Treesitter for installed languages",
    })

    vim.cmd("syntax enable")
  end,
}
