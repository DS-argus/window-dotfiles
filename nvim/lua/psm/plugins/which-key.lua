return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- modern preset은 기본 UI가 깔끔하고 Snacks와도 잘 어울린다.
		preset = "modern",
		delay = 200,
		win = {
			border = "rounded",
		},
		spec = {
			{ "<leader>f", group = "파일" },
			{ "<leader>g", group = "Git" },
			{ "<leader>n", group = "알림/Noice" },
			{ "<leader>s", group = "검색/창/치환" },
			{ "<leader>t", group = "탭/터미널" },
			{ "<leader>u", group = "토글" },
			{ "<leader>c", group = "코드" },
			{ "<leader>l", group = "린트/LSP" },
			{ "<leader>m", group = "포맷/마크다운" },
			{ "<leader>b", group = "버퍼" },
			{ "<leader>x", group = "문제" },
		},
	},
}
