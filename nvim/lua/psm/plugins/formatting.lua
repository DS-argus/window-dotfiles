return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_organize_imports", "ruff_format" },
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
		})

		-- 포맷은 code prefix에 묶어 두면 LSP 관련 작업과 기억하기 쉽다.
		vim.keymap.set({ "n", "v" }, "<leader>mf", function()
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 3000,
			})
		end, { desc = "파일 또는 선택 영역 포맷" })
	end,
}
