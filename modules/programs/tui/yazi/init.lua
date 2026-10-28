-- Show size and modification time.
function Linemode:size_mtime()
	local mtime_num = math.floor(self._file.cha.mtime or 0)
	local mtime_str
	if mtime_num == 0 then
		mtime_str = ""
	else
		mtime_str = os.date("%Y-%m-%d %H:%M", mtime_num)
	end

	local size = self._file:size()

	return string.format("%s %s", size and ya.readable_size(size) or "-", mtime_str)
end

-- Show symlink in status bar
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

-- Show user and group in status bar
Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)
