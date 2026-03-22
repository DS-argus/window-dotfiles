return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        -- 투명 배경 조합에서 경고가 뜨지 않도록 기본 배경색을 명시한다.
        background_colour = "#000000",
        timeout = 3000,
        render = "wrapped-compact",
      },
    },
  },
  opts = {
    -- noice는 cmdline/messages/popupmenu 계층을 맡는다.
    -- 예전처럼 ":" 입력 시 중앙 팝업이 뜨는 UX를 우선 복원한다.
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    messages = {
      enabled = true,
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    lsp = {
      -- 공식 README에서 권장하는 markdown/cmp 오버라이드를 그대로 사용한다.
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
      },
      signature = {
        enabled = true,
      },
    },
    presets = {
      -- 검색창도 하단 대신 팝업으로 띄워 command palette와 느낌을 맞춘다.
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  },
  config = function(_, opts)
    local notify = require("notify")

    -- 일반 vim.notify 호출도 noice/nvim-notify 파이프라인으로 흘려보낸다.
    vim.notify = notify

    require("noice").setup(opts)
  end,
  keys = {
    { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Noice 메시지 닫기" },
    { "<leader>nH", function() require("noice").cmd("history") end, desc = "Noice 기록" },
    { "<leader>nl", function() require("noice").cmd("last") end, desc = "마지막 메시지" },
  },
}
