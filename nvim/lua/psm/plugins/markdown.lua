return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		cmd = { "RenderMarkdown" },
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		main = "render-markdown",
		init = function()
			local group = vim.api.nvim_create_augroup("PsmMarkdownKeymaps", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = "markdown",
				callback = function(args)
					local buf = args.buf

					vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<CR>", {
						buffer = buf,
						desc = "마크다운 렌더링 on/off",
					})
				end,
			})
		end,
		config = function(_, opts)
			require("render-markdown").setup(opts)
		end,
		opts = {
			enabled = false,
			heading = {
				sign = false,
				position = "inline",
			},
			code = {
				enabled = false,
				sign = false,
			},
			file_types = { "markdown" },
			completions = {
				lsp = { enabled = true },
			},
		},
	},
}
