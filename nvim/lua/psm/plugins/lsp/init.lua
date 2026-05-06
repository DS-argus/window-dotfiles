return {
  {
    -- lazydev는 기존 neodev의 후속 방향이며, lua_ls가 Neovim runtime을 더 잘 이해하게 해 준다.
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local mason_tool_installer = require("mason-tool-installer")

      local servers = {
        "pyright",
        "lua_ls",
        "rust_analyzer",
      }

      mason.setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- LSP 서버와 formatter/linter를 분리해 두면 역할이 명확해진다.
      mason_lspconfig.setup({
        ensure_installed = servers,
        automatic_installation = false,
        automatic_enable = false,
      })

      mason_tool_installer.setup({
        ensure_installed = {
          "ruff",
          "stylua",
          "prettier",
        },
        run_on_start = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()
      local group = vim.api.nvim_create_augroup("PsmLspAttach", { clear = true })
      local python_root_markers = {
        "pyrightconfig.json",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git",
      }

      local function executable(cmd)
        local path = vim.fn.exepath(cmd)
        return path ~= "" and path or cmd
      end

      local function python_root_dir(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname == "" then
          return vim.uv.cwd()
        end

        return vim.fs.root(bufname, python_root_markers) or vim.fs.dirname(bufname)
      end

      local function python_path(root_dir)
        local candidates = {
          ".venv/Scripts/python.exe",
          "venv/Scripts/python.exe",
          ".venv/bin/python",
          "venv/bin/python",
        }

        if root_dir then
          for _, relpath in ipairs(candidates) do
            local candidate = vim.fs.joinpath(root_dir, relpath)
            if vim.uv.fs_stat(candidate) then
              return candidate
            end
          end
        end

        for _, cmd in ipairs({ "python3", "python" }) do
          local path = vim.fn.exepath(cmd)
          if path ~= "" and not path:match("WindowsApps[\\/]python%.exe$") then
            return path
          end
        end
      end

      -- Diagnostics는 Snacks picker와 statuscolumn에서 같이 소비하므로
      -- 부호/float/virtual text 스타일을 먼저 통일해 둔다.
      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
        float = {
          border = "rounded",
          source = "if_many",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰠠 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local buf = args.buf

          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, desc = desc })
          end

          -- 탐색은 Snacks picker가 맡고, 여기서는 "현재 심볼에 대한 행동" 위주만 둔다.
          map("gd", vim.lsp.buf.definition, "정의로 이동")
          map("gD", vim.lsp.buf.declaration, "선언으로 이동")
          map("gI", vim.lsp.buf.implementation, "구현으로 이동")
          map("gy", vim.lsp.buf.type_definition, "타입 정의로 이동")
          map("gR", vim.lsp.buf.references, "참조 찾기")
          map("K", vim.lsp.buf.hover, "심볼 문서 보기")
          map("gK", vim.lsp.buf.signature_help, "시그니처 도움말")
          map("<leader>ca", vim.lsp.buf.code_action, "코드 액션", { "n", "v" })
          map("<leader>rn", vim.lsp.buf.rename, "심볼 이름 변경")
          map("<leader>ld", vim.diagnostic.open_float, "라인 진단 보기")
          map("<leader>ls", function() Snacks.picker.lsp_symbols() end, "문서 심볼 보기")
          map("[d", vim.diagnostic.goto_prev, "이전 진단")
          map("]d", vim.diagnostic.goto_next, "다음 진단")
        end,
      })

      local servers = {
        lua_ls = {
          cmd = { executable("lua-language-server") },
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        pyright = {
          cmd = { executable("pyright-langserver"), "--stdio" },
          root_dir = function(bufnr, on_dir)
            on_dir(python_root_dir(bufnr))
          end,
          before_init = function(_, config)
            local path = python_path(config.root_dir)
            if not path then
              return
            end

            config.settings = config.settings or {}
            config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
              pythonPath = path,
            })
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "openFilesOnly",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                exclude = { "venv", ".venv", "__pycache__", "*.pyc" },
              },
            },
          },
        },
        rust_analyzer = {
          cmd = { executable("rust-analyzer") },
        },
      }

      for server, opts in pairs(servers) do
        opts.capabilities = capabilities
        vim.lsp.config(server, opts)
        vim.lsp.enable(server)
      end
    end,
  },
}
