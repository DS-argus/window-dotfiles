-- 설정에서 사용할 picker 관련 함수 미리 정의
local function snacks()
	return require("snacks")
end

local file_picker_title = "Files  ⏎ open  ^T tab  ^S/^V split  H/I filter"

local function find_files()
	snacks().picker.files({
		hidden = true,
		ignored = false,
		title = file_picker_title,
		win = {
			input = {
				keys = {
					["H"] = { "toggle_hidden", mode = { "n", "i" } },
					["I"] = { "toggle_ignored", mode = { "n", "i" } },
				},
			},
			list = {
				keys = {
					["H"] = "toggle_hidden",
					["I"] = "toggle_ignored",
				},
			},
		},
	})
end

local function find_text()
	snacks().picker.grep()
end

local function find_recent()
	snacks().picker.recent()
end

local function find_word()
	snacks().picker.grep_word()
end

local function find_todos()
	snacks().picker.grep({
		search = [[\b(TODO|FIX|FIXME|HACK|WARN|PERF|NOTE|TEST)\b]],
		regex = true,
		live = false,
		hidden = true,
	})
end

return {
	"folke/snacks.nvim",
	priority = 900,
	lazy = false,
	---@type snacks.Config
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
					{ icon = "󰱼 ", key = "p", desc = "Find File", action = find_files },
					{ icon = " ", key = "g", desc = "Find Text", action = find_text },
					{ icon = " ", key = "r", desc = "Recent Files", action = find_recent },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{
					{ section = "header" },
					{ section = "keys", gap = 1 },
					{ padding = 0.5, text = { { "", width = 0 } } },
					{
						icon = " ",
						title = "Recent Files",
						section = "recent_files",
						indent = 2,
						padding = 1,
					},
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{ section = "startup" },
				},
			},
		},
		indent = {
			enabled = true,
			indent = { char = "┊" },
			animate = {
				enabled = true,
				style = "out",
				easing = "linear",
				duration = { step = 20, total = 500 },
			},
			scope = { enabled = true },
			chunk = {
				enabled = true,
				only_current = true,
				priority = 200,
				hl = "SnacksIndentChunk",
				char = {
					corner_top = "╭",
					corner_bottom = "╰",
					horizontal = "─",
					vertical = "│",
					arrow = ">",
				},
			},
		},
		zen = {
			enabled = true,
			toggles = {
				dim = true,
				git_signs = false,
				mini_diff_signs = false,
				diagnostics = false,
				inlay_hints = false,
			},
			center = true,
			show = {
				statusline = true,
				tabline = false,
			},
			win = {
				style = "zen",
				width = 100,
				height = 0,
				backdrop = {
					transparent = false,
					blend = 45,
				},
			},
			zoom = {
				toggles = {},
				center = false,
				show = {
					statusline = true,
					tabline = true,
				},
				win = {
					backdrop = false,
					width = 0,
				},
			},
		},
		picker = { enabled = true },
		explorer = { enabled = false },
		input = { enabled = true },
	},
	keys = {
		{
			"<leader>sm",
			function()
				snacks().zen.zoom()
			end,
			desc = "분할 최대화 토글",
		},
		{
			"<leader>sz",
			function()
				snacks().zen()
			end,
			desc = "Zen 모드 토글",
		},
		{
			"<leader>ff",
			find_files,
			desc = "파일 찾기",
		},
		{
			"<leader>fr",
			find_recent,
			desc = "최근 파일 찾기",
		},
		{
			"<leader>fs",
			find_text,
			desc = "문자열 찾기",
		},
		{
			"<leader>fc",
			find_word,
			desc = "커서 아래 문자열 찾기",
		},
		{
			"<leader>ft",
			find_todos,
			desc = "TODO 찾기",
		},
	},
}
