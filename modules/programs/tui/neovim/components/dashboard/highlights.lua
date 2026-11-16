-- Keeps dashboard labels and file/project icons on the requested colors.
return function(icon_color)
	local function apply_dashboard_highlights()
		vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { link = "Function" })
		vim.api.nvim_set_hl(0, "SnacksDashboardFileIcon", { fg = icon_color })
		vim.api.nvim_set_hl(0, "SnacksDashboardDirIcon", { fg = icon_color })
	end

	apply_dashboard_highlights()

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = apply_dashboard_highlights,
	})
end
