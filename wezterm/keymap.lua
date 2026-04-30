local M = {}

local function disable_default_assignment(wezterm, key, mods)
	return {
		key = key,
		mods = mods,
		action = wezterm.action.DisableDefaultAssignment,
	}
end

function M.disable_multiplexing_defaults(config, wezterm)
	-- WezTerm 기본 키 중 tab/split/pane 이동처럼 외부 multiplexer와 겹치는 항목만 끈다.
	config.keys = {
		-- tab 생성/닫기
		disable_default_assignment(wezterm, "T", "CTRL"),
		disable_default_assignment(wezterm, "T", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "t", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "t", "SUPER"),
		disable_default_assignment(wezterm, "W", "CTRL"),
		disable_default_assignment(wezterm, "W", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "w", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "w", "SUPER"),

		-- tab 이동/번호 선택/순서 변경
		disable_default_assignment(wezterm, "Tab", "CTRL"),
		disable_default_assignment(wezterm, "Tab", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "PageUp", "CTRL"),
		disable_default_assignment(wezterm, "PageUp", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "PageDown", "CTRL"),
		disable_default_assignment(wezterm, "PageDown", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "[", "SHIFT|SUPER"),
		disable_default_assignment(wezterm, "]", "SHIFT|SUPER"),
		disable_default_assignment(wezterm, "{", "SUPER"),
		disable_default_assignment(wezterm, "{", "SHIFT|SUPER"),
		disable_default_assignment(wezterm, "}", "SUPER"),
		disable_default_assignment(wezterm, "}", "SHIFT|SUPER"),
		disable_default_assignment(wezterm, "!", "CTRL"),
		disable_default_assignment(wezterm, "!", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "@", "CTRL"),
		disable_default_assignment(wezterm, "@", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "#", "CTRL"),
		disable_default_assignment(wezterm, "#", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "$", "CTRL"),
		disable_default_assignment(wezterm, "$", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "%", "CTRL"),
		disable_default_assignment(wezterm, "%", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "^", "CTRL"),
		disable_default_assignment(wezterm, "^", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "&", "CTRL"),
		disable_default_assignment(wezterm, "&", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "*", "CTRL"),
		disable_default_assignment(wezterm, "*", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "(", "CTRL"),
		disable_default_assignment(wezterm, "(", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "1", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "1", "SUPER"),
		disable_default_assignment(wezterm, "2", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "2", "SUPER"),
		disable_default_assignment(wezterm, "3", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "3", "SUPER"),
		disable_default_assignment(wezterm, "4", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "4", "SUPER"),
		disable_default_assignment(wezterm, "5", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "5", "SUPER"),
		disable_default_assignment(wezterm, "6", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "6", "SUPER"),
		disable_default_assignment(wezterm, "7", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "7", "SUPER"),
		disable_default_assignment(wezterm, "8", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "8", "SUPER"),
		disable_default_assignment(wezterm, "9", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "9", "SUPER"),

		-- pane 분할/이동/리사이즈/확대
		disable_default_assignment(wezterm, '"', "ALT|CTRL"),
		disable_default_assignment(wezterm, '"', "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "'", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "%", "ALT|CTRL"),
		disable_default_assignment(wezterm, "%", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "5", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "LeftArrow", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "RightArrow", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "UpArrow", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "DownArrow", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "LeftArrow", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "RightArrow", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "UpArrow", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "DownArrow", "SHIFT|ALT|CTRL"),
		disable_default_assignment(wezterm, "Z", "CTRL"),
		disable_default_assignment(wezterm, "Z", "SHIFT|CTRL"),
		disable_default_assignment(wezterm, "z", "SHIFT|CTRL"),
	}
end

function M.apply(config, wezterm)
	local act = wezterm.action
	local utils = require("keymap_utils")

	-- 한글/IME 상태와 무관하게 tmux/vim 스타일 키맵이 안정적으로 동작하도록
	-- 물리 키 위치 기준으로 해석한다.
	config.key_map_preference = "Physical"

	-- tmux 와 같이 leader 설정 alt+space
	config.leader = {
		mods = "ALT",
		key = "Space",
		timeout_milliseconds = 2000,
	}

	-- 키맵은 tmux에 가깝게 유지하되,
	-- WezTerm 전용 기능(Search/QuickSelect/PaneSelect)도 같이 묶는다.
	config.keys = {
		-- 1) tab 관련
		--  tab 생성
		{ mods = "LEADER", key = "c", action = act.SpawnTab("CurrentPaneDomain") },
		--  tab 이름변경
		{
			mods = "LEADER",
			key = ",",
			action = act.PromptInputLine({
				description = "Rename tab",
				action = wezterm.action_callback(function(window, _, line)
					if line and #line > 0 then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		--  tab 이동 (next, previous)
		{ mods = "LEADER", key = "n", action = act.ActivateTabRelative(1) },
		{ mods = "LEADER", key = "p", action = act.ActivateTabRelative(-1) },

		-- 2) pane 관련
		--   pane 분할 (좌우: |, 상하: -)
		{ mods = "LEADER|SHIFT", key = "Backslash", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ mods = "LEADER", key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		--   pane 간 이동 (hjkl)
		{ mods = "ALT", key = "h", action = utils.split_nav(wezterm, "Left", "h") },
		{ mods = "ALT", key = "j", action = utils.split_nav(wezterm, "Down", "j") },
		{ mods = "ALT", key = "k", action = utils.split_nav(wezterm, "Up", "k") },
		{ mods = "ALT", key = "l", action = utils.split_nav(wezterm, "Right", "l") },
		--   현재 pane 확대 및 축소
		{ mods = "LEADER", key = "m", action = act.TogglePaneZoomState },
		--   번호로 pane 선택
		{ mods = "LEADER", key = "q", action = act.PaneSelect({ alphabet = "1234567890", show_pane_ids = true }) },
		--   ui 로 tab간 전환
		{ mods = "LEADER", key = "t", action = act.ShowLauncherArgs({ flags = "TABS" }) },
		-- 현재 탭 닫기
		{ mods = "LEADER", key = "x", action = act.CloseCurrentTab({ confirm = true }) },

		-- 3) workspace 관련 (tmux에서 세션개념)
		--  workspace 이름 변경
		{ mods = "LEADER", key = "r", action = utils.rename_workspace(wezterm) },
		--  workspace 이름 입력 후 전환, 없으면 새로 생성
		{ mods = "LEADER", key = "w", action = utils.switch_workspace(wezterm) },
		--  workspace 전환 (workspace, 하위 tab 선택가능)
		{ mods = "LEADER", key = "s", action = utils.select_workspace(wezterm) },
		--  unix domain에 attach
		{ mods = "LEADER", key = "u", action = act.AttachDomain("unix") },
		--  현재 domain에서 detach
		{ mods = "LEADER", key = "d", action = act.DetachDomain("CurrentPaneDomain") },

		-- 4) 기타
		--  Copy 모드 진입
		{ mods = "LEADER", key = "[", action = act.ActivateCopyMode },
		--  Copy 모드에서 특정 단어 검색
		{ mods = "LEADER", key = "f", action = act.Search("CurrentSelectionOrEmptyString") },
		--  주로 복사 대상인 것들을 빠르게 copy 가능 (url, git hash, path, ip addresses)
		{ mods = "LEADER", key = "o", action = act.QuickSelect },
		--  launcher 열기
		{ mods = "LEADER", key = "l", action = act.ShowLauncher },
	}
end

return M
