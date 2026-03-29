local M = {}

function M.apply(config, wezterm)
	-- Catppuccin Mocha 기반 공용 팔레트.
	-- tab, status, selection 색을 한 팔레트로 맞추기 위해 여기서 관리한다.
	local palette = {
		rosewater = "#f5e0dc",
		flamingo = "#f2cdcd",
		pink = "#f5c2e7",
		mauve = "#cba6f7",
		red = "#f38ba8",
		peach = "#fab387",
		yellow = "#f9e2af",
		green = "#a6e3a1",
		teal = "#94e2d5",
		sky = "#89dceb",
		sapphire = "#74c7ec",
		blue = "#89b4fa",
		lavender = "#b4befe",
		text = "#cdd6f4",
		subtext1 = "#bac2de",
		subtext0 = "#a6adc8",
		overlay1 = "#7f849c",
		overlay0 = "#6c7086",
		surface2 = "#585b70",
		surface1 = "#45475a",
		surface0 = "#313244",
		base = "#1e1e2e",
		mantle = "#181825",
		crust = "#11111b",
	}

	-- status 배지를 공통 형태(좌우 separator + 가운데 블록)로 그리는 헬퍼.
	local function push_badge(segments, outer_bg, inner_bg, fg, text)
		table.insert(segments, { Background = { Color = outer_bg } })
		table.insert(segments, { Foreground = { Color = inner_bg } })
		table.insert(segments, { Text = "" })
		table.insert(segments, { Background = { Color = inner_bg } })
		table.insert(segments, { Foreground = { Color = fg } })
		table.insert(segments, { Attribute = { Intensity = "Bold" } })
		table.insert(segments, { Text = text })
		table.insert(segments, { Background = { Color = outer_bg } })
		table.insert(segments, { Foreground = { Color = inner_bg } })
		table.insert(segments, { Text = "" })
		table.insert(segments, { Text = " " })
	end

	-- WezTerm 실행 시 기본 셸은 PowerShell 7로 통일한다.
	config.default_prog = { "pwsh.exe" }

	-- 본문은 JetBrains Mono Bold Oblique를 쓰고, 아이콘/한글은 별도 fallback으로 분리한다.
	config.font_size = 10
	config.font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono", weight = "Bold", style = "Oblique" },
		{ family = "Symbols Nerd Font Mono", weight = "Regular", style = "Normal" },
		{ family = "D2CodingLigature Nerd Font", weight = "Bold", style = "Oblique" },
	})

	-- 기본 터미널 색과 copy mode/selection 색을 같은 테마 계열로 맞춘다.
	config.colors = {
		foreground = palette.text,
		background = palette.base,
		cursor_bg = palette.rosewater,
		cursor_border = palette.rosewater,
		cursor_fg = palette.base,
		selection_bg = palette.sapphire,
		selection_fg = palette.crust,
		copy_mode_active_highlight_bg = { Color = palette.peach },
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

	-- 커서/스크롤백 기본 동작
	config.animation_fps = 120
	config.cursor_blink_ease_in = "EaseOut"
	config.cursor_blink_ease_out = "EaseOut"
	config.default_cursor_style = "BlinkingBlock"
	config.cursor_blink_rate = 800
	config.scrollback_lines = 10000

	config.enable_scroll_bar = false

	-- 탭바는 fancy 모드 대신 직접 그리는 탭 타이틀을 사용한다.
	config.enable_tab_bar = true
	config.use_fancy_tab_bar = false
	config.show_tab_index_in_tab_bar = false
	config.switch_to_last_active_tab_when_closing_tab = true
	config.tab_max_width = 25
	config.tab_bar_at_bottom = false
	config.show_new_tab_button_in_tab_bar = true

	-- 창 여백/프레임/투명도
	config.window_padding = {
		left = 0,
		right = 0,
		top = 5,
		bottom = 5,
	}
	config.window_frame = {
		font = wezterm.font("JetBrains Mono", { weight = "Bold", style = "Oblique" }),
		font_size = 10,
	}
	config.window_decorations = "INTEGRATED_BUTTONS"
	config.window_background_opacity = 0.90

	-- 탭을 Catppuccin 톤의 pill 형태로 직접 렌더링한다.
	-- active / inactive / hover 상태에 따라 배경과 글자색만 바꾼다.
	wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
		local theme = {
			bg = palette.base,
			inactive = palette.mantle,
			active = palette.blue,
			hover = palette.surface1,
			text = palette.text,
			inactive_text = palette.overlay1,
			active_text = palette.crust,
		}

		local bg = theme.inactive
		local fg = theme.inactive_text

		if tab.is_active then
			bg = theme.active
			fg = theme.active_text
		elseif hover then
			bg = theme.hover
			fg = theme.text
		end

		local tab_name = tab.tab_title
		if not tab_name or #tab_name == 0 then
			tab_name = "tab"
		end

		local zoom_prefix = ""
		if tab.active_pane and tab.active_pane.is_zoomed then
			zoom_prefix = "󰍉 "
		end

		local title = string.format("%sT%d. %s", zoom_prefix, tab.tab_index + 1, tab_name)
		-- 좌우 separator와 아이콘 공간을 고려해서 제목 길이를 미리 줄인다.
		title = wezterm.truncate_right(title, max_width - 4)

		return {
			{ Background = { Color = theme.bg } },
			{ Foreground = { Color = bg } },
			{ Text = "" },
			{ Background = { Color = bg } },
			{ Foreground = { Color = fg } },
			{ Text = " 󰆍 " .. title .. " " },
			{ Background = { Color = theme.bg } },
			{ Foreground = { Color = bg } },
			{ Text = "" },
		}
	end)

	-- 좌측 status는 입력 모드, 우측 status는 현재 domain/workspace를 보여준다.
	wezterm.on("update-status", function(window, pane)
		local left_status = {}

		-- leader가 활성화되면 눈에 띄는 주황색 배지를 표시한다.
		if window:leader_is_active() then
			push_badge(left_status, palette.base, palette.peach, palette.crust, " 󰘳 LEADER ")
		end

		-- copy mode에서는 별도 배지를 띄워 현재 상태를 즉시 알 수 있게 한다.
		if window:active_key_table() == "copy_mode" then
			push_badge(left_status, palette.base, palette.mauve, palette.crust, "  COPY ")
		end

		if #left_status > 0 then
			window:set_left_status(wezterm.format(left_status))
		else
			window:set_left_status("")
		end

		local workspace = window:active_workspace()
		local domain = "unknown"
		local active_pane = pane

		-- attach/detach 직후에는 전달된 pane 핸들이 아직 안정적이지 않을 수 있어서
		-- 필요하면 active pane을 다시 조회한다.
		if not active_pane then
			local ok_window_pane, window_pane = pcall(function()
				return window:active_pane()
			end)
			if ok_window_pane then
				active_pane = window_pane
			end
		end

		if active_pane then
			local ok_domain, pane_domain = pcall(function()
				return active_pane:get_domain_name()
			end)
			if ok_domain and pane_domain and #pane_domain > 0 then
				domain = pane_domain
			end
		end

		local domain_bg = palette.surface2
		if domain == "unix" then
			domain_bg = palette.green
		elseif domain == "local" then
			domain_bg = palette.blue
		end

		-- 우측은 domain과 workspace를 각각 pill로 강조해서 표시한다.
		window:set_right_status(wezterm.format({
			{ Background = { Color = palette.base } },
			{ Foreground = { Color = domain_bg } },
			{ Text = "" },
			{ Background = { Color = domain_bg } },
			{ Foreground = { Color = palette.crust } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " 󰒋 " .. domain .. " " },
			{ Background = { Color = palette.base } },
			{ Foreground = { Color = domain_bg } },
			{ Text = "" },
			{ Text = " " },
			{ Foreground = { Color = palette.lavender } },
			{ Text = "" },
			{ Background = { Color = palette.surface0 } },
			{ Foreground = { Color = palette.text } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " 󱂬 " .. workspace .. " " },
			{ Background = { Color = palette.base } },
			{ Foreground = { Color = palette.surface0 } },
			{ Text = "" },
		}))
	end)
end

return M
