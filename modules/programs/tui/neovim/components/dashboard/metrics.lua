-- Caches startup timing and plugin counts after the UI attaches.
vim.g.snacks_dashboard_start_ns = vim.uv.hrtime()
vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		local start_plugins = vim.fn.globpath(vim.o.packpath, "pack/*/start/*", 0, 1)
		local opt_plugins = vim.fn.globpath(vim.o.packpath, "pack/*/opt/*", 0, 1)
		local loaded = 0

		for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
			if path:find("/pack/", 1, true) and (path:find("/start/", 1, true) or path:find("/opt/", 1, true)) then
				loaded = loaded + 1
			end
		end

		vim.g.snacks_dashboard_metrics = {
			loaded = loaded,
			ms = (vim.uv.hrtime() - vim.g.snacks_dashboard_start_ns) / 1e6,
			total = #start_plugins + #opt_plugins,
		}
	end,
})
