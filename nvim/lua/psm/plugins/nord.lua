return {
	"gbprod/nord.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local transparent = true

		require("nord").setup({
			transparent = transparent,
			terminal_colors = true,
			diff = { mode = "bg" },
			borders = true,
			errors = { mode = "bg" },
			search = { theme = "vim" },
			styles = {
				comments = { italic = true },
				keywords = {},
				functions = {},
				variables = {},
			},
			on_highlights = function(highlights, colors)
				if not transparent then
					return
				end

				for _, group in ipairs({
					"NormalFloat",
					"FloatBorder",
					"FoldColumn",
					"StatusLine",
					"StatusLineNC",
				}) do
					if highlights[group] then
						highlights[group].bg = colors.none
					end
				end
			end,
		})

		vim.cmd.colorscheme("nord")
	end,
}
