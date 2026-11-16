-- Decides which documents may reach GitHub Copilot using the sensitive-path globs
-- only. Paths may be sent; contents of matching files may not. Nothing is cached,
-- so a rename or symlink retarget applies to the next message.
return function(ignore_paths)
	local M = {}

	local patterns = vim.tbl_map(function(glob)
		return { has_slash = glob:find("/", 1, true) ~= nil, lpeg = vim.glob.to_lpeg(glob) }
	end, ignore_paths)

	-- Methods whose payload may be read from the focused buffer rather than the URI's buffer.
	local focus_methods = {
		["textDocument/didChange"] = true,
		["textDocument/didFocus"] = true,
		["textDocument/inlineCompletion"] = true,
	}

	local function matches(path)
		local lower = path:lower()
		local name = vim.fs.basename(lower)
		for _, pattern in ipairs(patterns) do
			if pattern.lpeg:match(pattern.has_slash and lower or name) then
				return true
			end
		end
		return false
	end

	-- Resolves symlinks, using the nearest existing ancestor for paths not yet written.
	local function realpath(path)
		local suffix = {}
		local current = path
		while current ~= "/" and current ~= "." and current ~= "" do
			local real = vim.uv.fs_realpath(current)
			if real then
				return vim.fs.joinpath(real, unpack(suffix))
			end
			table.insert(suffix, 1, vim.fs.basename(current))
			current = vim.fs.dirname(current)
		end
		return path
	end

	-- Unnamed buffers are allowed; named ones are checked as written and as resolved.
	function M.path_blocked(path)
		if type(path) ~= "string" or path == "" then
			return false
		end
		path = vim.fs.normalize(path, { expand_env = false })
		return matches(path) or matches(realpath(path))
	end

	-- Checks the path part of any scheme, so fugitive:// or oil:// views of secrets stay blocked.
	function M.uri_blocked(uri)
		if type(uri) ~= "string" then
			return false
		end
		local path = uri:match("^file://(.*)$") and vim.uri_to_fname(uri) or uri:gsub("^%a[%w+.-]*://", "/")
		return M.path_blocked(path)
	end

	-- Content-bearing messages name their document in textDocument.uri.
	local function message_blocked(method, params)
		local current = vim.api.nvim_get_current_buf()
		local focus = focus_methods[method] or method:lower():find("copilot") ~= nil
		if focus and M.path_blocked(vim.api.nvim_buf_get_name(current)) then
			return true
		end
		local document = type(params) == "table" and params.textDocument
		return type(document) == "table" and M.uri_blocked(document.uri)
	end

	-- Wraps the transport so every outbound message passes the policy.
	function M.wrap(client)
		local rpc = client.rpc
		local notify, request = rpc.notify, rpc.request
		rpc.notify = function(method, params)
			if message_blocked(method, params) then
				return true
			end
			return notify(method, params)
		end
		rpc.request = function(method, params, callback, notify_reply_callback)
			if message_blocked(method, params) then
				return false
			end
			return request(method, params, callback, notify_reply_callback)
		end
	end

	function M.root_dir(bufnr, on_dir)
		if not M.path_blocked(vim.api.nvim_buf_get_name(bufnr)) then
			on_dir(vim.uv.cwd())
		end
	end

	return M
end
