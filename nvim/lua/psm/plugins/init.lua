return {
  "nvim-lua/plenary.nvim",
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Move to left pane" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Move to lower pane" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Move to upper pane" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Move to right pane" },
      { "<M-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Move to left pane" },
      { "<M-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Move to lower pane" },
      { "<M-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Move to upper pane" },
      { "<M-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Move to right pane" },
    },
  },
}
