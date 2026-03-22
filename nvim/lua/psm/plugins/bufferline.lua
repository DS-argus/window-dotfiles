return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	config = function()
		-- Snacks picker가 버퍼 전환을 잘 해 주더라도,
		-- 상단에 현재 열린 버퍼 목록이 보이면 컨텍스트 파악이 훨씬 쉽다.
		require("bufferline").setup({
			options = {
				mode = "buffers",
				separator_style = "slant",
				diagnostics = "nvim_lsp",
				show_close_icon = false,
				show_buffer_close_icons = false,
				always_show_bufferline = false,
			},
		})

		vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "다음 버퍼" })
		vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "이전 버퍼" })
	end,
}
