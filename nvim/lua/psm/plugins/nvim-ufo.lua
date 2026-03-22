return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	event = "BufRead",
	config = function()
		-- fold 관련 기본 옵션은 ufo가 provider를 고르기 전에 먼저 맞춰 둔다.
		vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
		vim.o.foldcolumn = "0"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
		require("ufo").setup({
			-- Treesitter가 있으면 구조 기반 folding을 우선, 아니면 indent 기반으로 fallback 한다.
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
		})

		vim.keymap.set("n", "zR", function()
			require("ufo").openAllFolds()
		end, { desc = "모든 fold 열기" })

		vim.keymap.set("n", "zM", function()
			require("ufo").closeAllFolds()
		end, { desc = "모든 fold 닫기" })
	end,
}
