-- Renders jj-starship output as a lualine component that refreshes on jj operations.
return function(palette)
	if vim.fn.executable("jj-starship") ~= 1 then
		return {
			component = function()
				return ""
			end,
			is_in_workspace = function()
				return false
			end,
		}
	end

	-- ANSI codes emitted by jj-starship, mapped to palette colors.
	local ansi_colors = {
		["31"] = { name = "status", color = palette.error },
		["32"] = { name = "bookmark", color = palette.success },
		["33"] = { name = "status_empty", color = palette.warning },
		["34"] = { name = "symbol", color = palette.info },
		["35"] = { name = "change", color = palette.accent },
		["90"] = { name = "rest", color = palette.muted },
		["95"] = { name = "prefix", color = palette.accent },
	}

	local state = { buffer = -1, root = nil, text = "" }
	local job = nil
	local watcher = nil
	local load

	local function workspace_root(bufnr)
		local source = vim.api.nvim_buf_get_name(bufnr) ~= "" and bufnr or vim.fn.getcwd()

		return vim.fs.root(source, ".jj")
	end

	local function starship(buffer, root)
		job = vim.system({ "jj-starship", "--cwd", root }, { text = true }, function(completed)
			job = nil

			if completed.code ~= 0 or state.buffer ~= buffer then
				return
			end

			local text = vim.trim(((completed.stdout or ""):gsub("^on ", "")))

			vim.schedule(function()
				state.text = text

				require("lualine").refresh()
			end)
		end)
	end

	local function watch(root)
		if watcher then
			watcher:stop()
			watcher = nil
		end

		if not root then
			return
		end

		-- jj rewrites op heads on every operation, so watch them for changes.
		local op_heads = vim.fs.joinpath(root, ".jj", "repo", "op_heads", "heads")

		if vim.uv.fs_stat(op_heads) then
			watcher = assert(vim.uv.new_fs_event())
			watcher:start(op_heads, {}, vim.schedule_wrap(load))
		end
	end

	load = function()
		local buffer = vim.api.nvim_get_current_buf()
		local root = workspace_root(buffer)

		if job then
			job:kill(15)
			job = nil
		end

		if root ~= state.root then
			watch(root)
		end

		state.buffer, state.root, state.text = buffer, root, ""

		if root then
			starship(buffer, root)
		end
	end

	local function highlight(self, code)
		local ansi_style = ansi_colors[code]

		if not ansi_style then
			return ""
		end

		self.highlights = self.highlights or {}

		if not self.highlights[code] then
			self.highlights[code] = self:create_hl({ fg = ansi_style.color }, "jj_" .. ansi_style.name)
		end

		return self:format_hl(self.highlights[code])
	end

	local function parse(text)
		local tokens = {}
		local position = 1

		while true do
			local start_index, end_index, code = text:find("\27%[(%d+)m", position)

			if not start_index then
				tokens[#tokens + 1] = { text = text:sub(position) }

				break
			end

			if start_index > position then
				tokens[#tokens + 1] = { text = text:sub(position, start_index - 1) }
			end

			tokens[#tokens + 1] = { code = code }
			position = end_index + 1
		end

		return tokens
	end

	local function render(self, tokens)
		local parts = {}

		for _, token in ipairs(tokens) do
			parts[#parts + 1] = token.code and highlight(self, token.code) or token.text or ""
		end

		return table.concat(parts)
	end

	local function component(self)
		if state.buffer ~= vim.api.nvim_get_current_buf() or state.text == "" then
			return ""
		end

		return render(self, parse(state.text))
	end

	local function is_in_workspace()
		return state.buffer == vim.api.nvim_get_current_buf() and state.root ~= nil
	end

	vim.api.nvim_create_autocmd({ "UIEnter", "BufEnter", "BufWritePost", "FocusGained" }, {
		group = vim.api.nvim_create_augroup("jj-lualine", {}),
		callback = load,
	})

	load()

	return { component = component, is_in_workspace = is_in_workspace }
end
