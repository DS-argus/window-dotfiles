return {
  {
    "mrjones2014/smart-splits.nvim",
    branch = "master",
    lazy = false,
    opts = {
      ignored_filetypes = { "NvimTree" },
      multiplexer_integration = "wezterm",
      disable_multiplexer_nav_when_zoomed = false,
    },
    config = function(_, opts)
      local smart_splits = require("smart-splits")

      smart_splits.setup(opts)

      -- macOS에서 쓰던 Alt-hjkl 흐름을 그대로 유지한다.
      vim.keymap.set("n", "<A-h>", smart_splits.move_cursor_left, { desc = "왼쪽 pane으로 이동" })
      vim.keymap.set("n", "<A-j>", smart_splits.move_cursor_down, { desc = "아래 pane으로 이동" })
      vim.keymap.set("n", "<A-k>", smart_splits.move_cursor_up, { desc = "위 pane으로 이동" })
      vim.keymap.set("n", "<A-l>", smart_splits.move_cursor_right, { desc = "오른쪽 pane으로 이동" })
    end,
  },
}
