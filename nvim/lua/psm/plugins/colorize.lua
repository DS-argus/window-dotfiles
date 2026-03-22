return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		-- CSS/Tailwind뿐 아니라 설정 파일의 HEX 코드도 바로 보이도록 전 파일에 켠다.
		filetypes = { "*" },
		user_default_options = {
			names = false,
		},
	},
}
