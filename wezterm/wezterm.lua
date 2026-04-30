-- WezTerm 메인 엔트리 파일.
-- 실제 설정은 역할별 모듈로 나누고 여기서는 로드만
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- WezTerm의 내장 multiplexing(tab/workspace/pane/domain)을 쓸지 결정한다.
-- psmux처럼 외부 multiplexer를 쓸 때는 false로 두면 관련 UI와 키맵이 같이 꺼진다.
local enable_multiplexing = false

local options = {
	multiplexing = enable_multiplexing,
}

if enable_multiplexing then
	config.unix_domains = {
		{
			name = "unix",
		},
	}
end

-- 화면/스타일 관련 설정
require("ui").apply(config, wezterm, options)

if enable_multiplexing then
	-- 키맵, workspace, pane 이동 관련 설정
	require("keymap").apply(config, wezterm)
end

return config
