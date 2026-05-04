local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ---------------------------------------------------------------------------
-- Palette
-- ---------------------------------------------------------------------------
-- Catppuccin Mocha 색상만 직접 들고 간다. 별도 테마 플러그인이나 탭바
-- 렌더링 없이도 터미널 본문, 선택 영역, copy mode 색을 한 톤으로 맞춘다.
local palette = {
	rosewater = "#f5e0dc",
	red = "#f38ba8",
	yellow = "#f9e2af",
	green = "#a6e3a1",
	teal = "#94e2d5",
	blue = "#89b4fa",
	mauve = "#cba6f7",
	text = "#cdd6f4",
	subtext1 = "#bac2de",
	overlay0 = "#6c7086",
	overlay1 = "#7f849c",
	surface2 = "#585b70",
	sapphire = "#74c7ec",
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}

-- ---------------------------------------------------------------------------
-- Shell
-- ---------------------------------------------------------------------------
-- WezTerm은 단일 터미널 창 역할만 맡기고, multiplexing은 psmux가 담당한다.
config.default_prog = { "pwsh.exe" }

-- ---------------------------------------------------------------------------
-- Font
-- ---------------------------------------------------------------------------
-- 본문 폰트와 아이콘/한글 fallback을 분리한다.
config.font_size = 10
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Bold", style = "Oblique" },
	{ family = "Symbols Nerd Font Mono", weight = "Regular", style = "Normal" },
	{ family = "D2CodingLigature Nerd Font", weight = "Bold", style = "Oblique" },
})

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------
-- psmux statusbar가 내부에서 색을 직접 그리므로, 여기서는 터미널 기본색과
-- 선택/copy-mode highlight만 잡는다.
config.colors = {
	foreground = palette.text,
	background = palette.base,
	cursor_bg = palette.rosewater,
	cursor_border = palette.rosewater,
	cursor_fg = palette.base,
	selection_bg = palette.sapphire,
	selection_fg = palette.crust,
	copy_mode_active_highlight_bg = { Color = palette.yellow },
	copy_mode_active_highlight_fg = { Color = palette.crust },
	copy_mode_inactive_highlight_bg = { Color = palette.surface2 },
	copy_mode_inactive_highlight_fg = { Color = palette.text },
	ansi = {
		palette.overlay0,
		palette.red,
		palette.green,
		palette.yellow,
		palette.blue,
		palette.mauve,
		palette.teal,
		palette.subtext1,
	},
	brights = {
		palette.overlay1,
		palette.red,
		palette.green,
		palette.yellow,
		palette.blue,
		palette.mauve,
		palette.teal,
		palette.text,
	},
}

-- ---------------------------------------------------------------------------
-- Multiplexing
-- ---------------------------------------------------------------------------
-- WezTerm 내장 tab/pane/workspace/domain 기능은 쓰지 않는다.
-- 기본 키맵도 꺼서 Ctrl+Shift 계열 tab/split 단축키가 실수로 동작하지 않게 한다.
config.enable_tab_bar = false
config.disable_default_key_bindings = true
config.key_map_preference = "Physical"

-- ---------------------------------------------------------------------------
-- Keys
-- ---------------------------------------------------------------------------
-- WezTerm 자체 키는 클립보드와 폰트 크기 조절만 남긴다.
-- pane/window/session 조작은 전부 psmux 설정을 따른다.
config.keys = {
	{ key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
	{ key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
	{ key = "_", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
	{ key = ")", mods = "CTRL|SHIFT", action = act.ResetFontSize },
}

-- ---------------------------------------------------------------------------
-- Terminal Behavior
-- ---------------------------------------------------------------------------
-- 커서와 스크롤백처럼 터미널 자체 동작에 해당하는 값만 유지한다.
config.animation_fps = 120
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------
-- psmux pane border가 창 안쪽 끝까지 붙도록 좌우 padding은 제거하고,
-- 위아래만 살짝 둔다.
config.window_padding = {
	left = 0,
	right = 0,
	top = 5,
	bottom = 5,
}

config.window_background_opacity = 0.9

return config
