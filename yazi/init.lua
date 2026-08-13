require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

require("session"):setup({
	sync_yanked = true,
})

-- Make the active SFTP connection obvious without replacing the CWD display.
-- Keep the badge fixed in the top-right header so long paths do not move it.
Header:children_add(function()
	local cwd = cx.active.current.cwd
	if cwd.domain == "mac" then
		return ui.Line {
			ui.Span("   MAC "):fg("#ffffff"):bg("#dc2626"):bold(),
			ui.Span(" SFTP "):fg("#fecaca"):bg("#7f1d1d"):bold(),
			ui.Span(" "),
		}
	end
	return ""
end, 3000, Header.RIGHT)

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
