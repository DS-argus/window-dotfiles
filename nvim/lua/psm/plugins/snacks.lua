return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Snacks는 이제 picker/dashboard/terminal 같은 보조 UX 계층에 집중한다.
      -- 파일 트리는 nvim-tree, cmdline/messages는 noice가 맡도록 역할을 분리한다.
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          keys = {
            {
              icon = " ",
              key = "e",
              desc = "새 파일",
              action = ":ene | startinsert",
            },
            {
              icon = " ",
              key = "f",
              desc = "파일 탐색기",
              action = ":NvimTreeToggle",
            },
            {
              icon = "󰱼 ",
              key = "p",
              desc = "파일 찾기",
              action = function()
                Snacks.picker.files()
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "문자열 찾기",
              action = function()
                Snacks.picker.grep()
              end,
            },
            {
              icon = " ",
              key = "r",
              desc = "최근 파일",
              action = function()
                Snacks.picker.recent()
              end,
            },
            {
              icon = " ",
              key = "q",
              desc = "NVIM 종료",
              action = ":qa",
            },
          },
        },
      },
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = false },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      terminal = { enabled = true },
      lazygit = { enabled = true },
      gitbrowse = { enabled = true },
      scratch = { enabled = true },
      zen = { enabled = true },
      dim = { enabled = true },
    },
    init = function()
      -- VeryLazy 이후에 toggle을 연결하면 which-key와 설명이 자연스럽게 합쳐진다.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.option("spell", { name = "맞춤법 검사" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "줄바꿈" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "상대 줄번호" }):map("<leader>uL")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.option("conceallevel", {
            off = 0,
            on = 2,
            name = "conceal",
          }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", {
            off = "light",
            on = "dark",
            name = "배경 테마",
          }):map("<leader>ub")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")

          if vim.lsp.inlay_hint then
            Snacks.toggle.inlay_hints():map("<leader>uh")
          end
        end,
      })
    end,
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "스마트 picker" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "버퍼 목록" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "프로젝트 전체 검색" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "명령 기록" },
      { "<leader>nn", function() Snacks.picker.notifications() end, desc = "알림 목록" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "버퍼 찾기" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "파일 찾기" },
      { "<leader>fC", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Neovim 설정 파일" },
      { "<leader>fc", function() Snacks.picker.grep_word() end, desc = "커서 아래 문자열 찾기" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git 추적 파일" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "도움말" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "프로젝트 찾기" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "최근 파일" },
      { "<leader>fs", function() Snacks.picker.grep() end, desc = "문자열 찾기" },
      {
        "<leader>ft",
        function()
          Snacks.picker.grep({
            search = [[\b(TODO|FIX|FIXME|HACK|WARN|PERF|NOTE|TEST)\b]],
            regex = true,
            live = false,
            hidden = true,
          })
        end,
        desc = "TODO 찾기",
      },

      { '<leader>s"', function() Snacks.picker.registers() end, desc = "레지스터" },
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "검색 기록" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "자동 명령" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "현재 버퍼 줄 검색" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "열린 버퍼 검색" },
      { "<leader>sc", function() Snacks.picker.commands() end, desc = "명령 목록" },
      { "<leader>sC", function() Snacks.picker.colorschemes() end, desc = "색상 테마" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "전체 진단" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "현재 버퍼 진단" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "프로젝트 grep" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "하이라이트 그룹" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "아이콘" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "점프 목록" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "키맵 목록" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location list" },
      { "<leader>sm", function() Snacks.zen.zoom() end, desc = "분할 최대화 토글" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "매뉴얼 페이지" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "플러그인 spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix list" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "문서 심볼" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "워크스페이스 심볼" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo 기록" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "커서 단어 검색" },

      { "<leader>gb", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "원격 저장소에서 열기" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "현재 파일 Git 로그" },
      { "<leader>lg", function() Snacks.lazygit() end, desc = "LazyGit" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git 로그" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "현재 줄 Git 로그" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git 상태" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git stash" },

      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "정의로 이동" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "선언으로 이동" },
      { "gR", function() Snacks.picker.lsp_references() end, nowait = true, desc = "참조 찾기" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "구현 찾기" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "타입 정의 찾기" },

      { "<leader>.", function() Snacks.scratch() end, desc = "스크래치 버퍼" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "스크래치 목록" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "현재 버퍼 닫기" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "파일 이름 변경" },

      { "<leader>tt", function() Snacks.terminal() end, desc = "내장 터미널" },
      { "<leader>tz", function() Snacks.zen() end, desc = "Zen 모드" },
      { "<leader>tZ", function() Snacks.zen.zoom() end, desc = "현재 창 확대" },
      { "<C-/>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "터미널 토글" },
      { "<C-_>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "터미널 토글" },

      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "다음 참조" },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "이전 참조" },
    },
  },
}
