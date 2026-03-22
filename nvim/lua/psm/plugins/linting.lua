return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local lint_enabled = false

		lint.linters_by_ft = {
			python = { "ruff" },
		}

		local function clear_lint()
			vim.diagnostic.reset(nil, 0)
		end

		vim.keymap.set("n", "<leader>lt", function()
			lint_enabled = not lint_enabled
			if lint_enabled then
				vim.notify("Linting Enabled")
				lint.try_lint()
			else
				vim.notify("Linting Disabled")
				clear_lint()
			end
		end, { desc = "Toggle linting on/off" })

		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "현재 파일 lint 실행" })
	end,
}
