-- Adjusts local UI behavior while the Snacks dashboard buffer is active.
local function configure_dashboard_ui()
	if vim.bo.filetype ~= "snacks_dashboard" then
		return
	end

	vim.opt_local.scrolloff = 0
	vim.b.snacks_scroll = false

	if vim.g.dashboard_saved_mouse == nil then
		vim.g.dashboard_saved_mouse = vim.go.mouse
	end

	vim.go.mouse = ""

	local group = vim.api.nvim_create_augroup("dashboard_mouse_restore", { clear = true })
	local function restore_mouse()
		local saved_mouse = vim.g.dashboard_saved_mouse
		if vim.bo.filetype == "snacks_dashboard" or saved_mouse == nil then
			return
		end

		vim.go.mouse = saved_mouse
		vim.g.dashboard_saved_mouse = nil
		pcall(vim.api.nvim_del_augroup_by_id, group)
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
		group = group,
		callback = restore_mouse,
	})

	vim.schedule(function()
		vim.o.laststatus = 3
		vim.o.showtabline = 2
		require("lualine").refresh({ force = true, place = { "statusline", "tabline" } })
	end)
end

function _G.open_snacks_dashboard()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype ~= "snacks_dashboard" then
		buf = vim.api.nvim_create_buf(false, true)
	end

	return Snacks.dashboard.open({
		buf = buf,
		win = vim.api.nvim_get_current_win(),
	})
end

vim.api.nvim_create_autocmd("User", {
	pattern = "SnacksDashboardOpened",
	callback = configure_dashboard_ui,
})
