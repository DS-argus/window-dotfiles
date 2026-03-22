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
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "openFilesOnly",
                autoSearchPaths = false,
                useLibraryCodeForTypes = false,
                exclude = { "venv", ".venv", "__pycache__", "*.pyc" },
              },
            },
          },
        },
        rust_analyzer = {},
      }

      for server, opts in pairs(servers) do
        opts.capabilities = capabilities
        vim.lsp.config(server, opts)
        vim.lsp.enable(server)
      end
    end,
  },
}
