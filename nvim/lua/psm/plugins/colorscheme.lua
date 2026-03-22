return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			local transparent = true

			local bg = "#011628"
			local bg_dark = "#011423"
			local bg_highlight = "#143652"
			local bg_search = "#0A64AC"
			local bg_visual = "#275378"
			local fg = "#CBE0F0"
			local fg_dark = "#B4D0E9"
			local fg_gutter = "#627E97"
			local border = "#547998"

			-- 현재 WezTerm 배경과 잘 어울리도록 night 변형을 직접 튜닝한다.
			require("tokyonight").setup({
				style = "night",
				transparent = transparent,
				styles = {
					sidebars = transparent and "transparent" or "dark",
					floats = transparent and "transparent" or "dark",
				},
				on_colors = function(colors)
					colors.bg = bg
					colors.bg_dark = transparent and colors.none or bg_dark
					colors.bg_float = transparent and colors.none or bg_dark
					colors.bg_highlight = bg_highlight
					colors.bg_popup = bg_dark
					colors.bg_search = bg_search
					colors.bg_sidebar = transparent and colors.none or bg_dark
					colors.bg_statusline = transparent and colors.none or bg_dark
					colors.bg_visual = bg_visual
					colors.border = border
					colors.fg = fg
					colors.fg_dark = fg_dark
					colors.fg_float = fg
					colors.fg_gutter = fg_gutter
					colors.fg_sidebar = fg_dark
				end,
				on_highlights = function(highlights)
					-- 주석이 WezTerm 투명 배경 위에서도 묻히지 않도록 한 단계 더 또렷하게 올린다.
					highlights.Comment = { fg = "#7A88B5", italic = true }
				end,
			})
			-- colorscheme은 다른 UI 플러그인보다 먼저 적용되어야 색이 안정적이다.
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}
