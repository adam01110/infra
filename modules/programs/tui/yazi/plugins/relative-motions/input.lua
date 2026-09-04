-- selene: allow(undefined_variable)
local append_digit = ya.sync(function(state, digit)
	local now = ya.time()
	if not state.updated_at or now - state.updated_at > 3 then
		state.count = 0
	end

	state.count = math.min((state.count or 0) * 10 + digit, 9999)
	state.updated_at = now
end)

-- selene: allow(undefined_variable)
local take_count = ya.sync(function(state)
	local now = ya.time()
	local count = state.count
	if not state.updated_at or now - state.updated_at > 3 then
		count = nil
	end

	state.count = nil
	state.updated_at = nil
	return count or 1
end)

-- selene: allow(undefined_variable)
return {
	entry = function(_, job)
		local action = job.args[1]
		if action:sub(1, 6) == "append" then
			append_digit(tonumber(action:sub(7)))
			return
		end

		local count = take_count()
		if action == "down" then
			ya.emit("arrow", { count })
		elseif action == "up" then
			ya.emit("arrow", { -count })
		end
	end,
}
