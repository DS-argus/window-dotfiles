return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {},
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "문제 목록 토글" },
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "워크스페이스 진단 보기" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "현재 파일 진단 보기" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "퀵픽스 목록 보기" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "위치 목록 보기" },
    { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODO 목록 보기" },
  },
}
