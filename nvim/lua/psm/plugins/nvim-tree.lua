return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "NvimTreeOpen",
    "NvimTreeToggle",
    "NvimTreeFocus",
    "NvimTreeFindFile",
    "NvimTreeFindFileToggle",
    "NvimTreeCollapse",
    "NvimTreeRefresh",
  },
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        if vim.fn.argc() ~= 1 then
          return
        end

        local arg = vim.fn.argv(0)
        if type(arg) ~= "string" or arg == "" or vim.fn.isdirectory(arg) == 0 then
          return
        end

        local dir = vim.fn.fnamemodify(arg, ":p")
        vim.schedule(function()
          vim.cmd.cd(dir)
          vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(dir))
        end)
      end,
    })
  end,
  keys = {
    { "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "파일 트리 토글" },
    { "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "현재 파일 기준 트리 토글" },
    { "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "파일 트리 접기" },
    { "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "파일 트리 새로고침" },
  },
  opts = function()
    local api = require("nvim-tree.api")

    local function on_attach(bufnr)
      -- 기본 매핑은 유지하되, 홈로우 이동과 도움말만 추가로 다듬는다.
      api.config.mappings.default_on_attach(bufnr)

      local function opts(desc)
        return {
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
          desc = "nvim-tree: " .. desc,
        }
      end

      vim.keymap.set("n", "?", api.tree.toggle_help, opts("도움말"))
      vim.keymap.set("n", "l", api.node.open.edit, opts("열기"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("부모로 접기"))
      vim.keymap.set("n", "v", api.node.open.vertical, opts("세로 분할로 열기"))
      vim.keymap.set("n", "s", api.node.open.horizontal, opts("가로 분할로 열기"))
    end

    return {
      on_attach = on_attach,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
      git = {
        ignore = false,
      },
      filters = {
        dotfiles = false,
      },
      view = {
        width = 36,
        relativenumber = true,
      },
      renderer = {
        root_folder_label = false,
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
          },
        },
      },
      actions = {
        open_file = {
          resize_window = true,
          window_picker = {
            enable = false,
          },
        },
      },
    }
  end,
}
