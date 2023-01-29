local M = {}

M.decode = function()
	local row1, col1 = unpack(vim.fn.getpos("v"), 2, 3)
	local row2, col2 = unpack(vim.api.nvim_win_get_cursor(0))
	local content = vim.api.nvim_buf_get_text(0, row1 - 1, col1 - 1, row2 - 1, col2 + 1, {})
	local text = table.concat(content, "\n")
	local decoded = vim.fn.system({ "base64", "--decode" }, text)
	decoded = string.gsub(decoded, "%s+", "")

	local Popup = require("nui.popup")
	local popup = Popup({
		border = {
			padding = { 1, 1 },
			style = "rounded",
			text = {
				bottom = "[u]pdate or [q]uit",
				bottom_align = "right",
				top = "Base64 decoded:",
				top_align = "left",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		enter = true,
		focusable = true,
		position = 1,
		relative = "cursor",
		size = {
			width = "50%",
			height = 5,
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	})
	local parent_buf = vim.api.nvim_get_current_buf()
	popup:map("n", "q", function(_)
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:map("n", "u", function(_)
		local updated_content = vim.api.nvim_buf_get_text(popup.bufnr, 0, 0, -1, -1, {})
		local encoded = vim.fn.system({ "base64", "--wrap", "0" }, updated_content)
		vim.api.nvim_buf_set_text(parent_buf, row1 - 1, col1 - 1, row2 - 1, col2 + 1, { encoded })
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:mount()
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { decoded })
end

M.encode = function()
	local row1, col1 = unpack(vim.fn.getpos("v"), 2, 3)
	local row2, col2 = unpack(vim.api.nvim_win_get_cursor(0))
	local content = vim.api.nvim_buf_get_text(0, row1 - 1, col1 - 1, row2 - 1, col2 + 1, {})
	local text = table.concat(content, "\n")
	local encoded = vim.fn.system({ "base64", "--wrap", "0" }, text)
	encoded = string.gsub(encoded, "%s+", "")

	local Popup = require("nui.popup")
	local popup = Popup({
		border = {
			padding = { 1, 1 },
			style = "rounded",
			text = {
				bottom = "[u]pdate or [q]uit",
				bottom_align = "right",
				top = "Base64 encoded:",
				top_align = "left",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		enter = true,
		focusable = true,
		position = 1,
		relative = "cursor",
		size = {
			width = "50%",
			height = 5,
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	})
	local parent_buf = vim.api.nvim_get_current_buf()
	popup:map("n", "q", function(_)
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:map("n", "u", function(_)
		vim.api.nvim_buf_set_text(parent_buf, row1 - 1, col1 - 1, row2 - 1, col2 + 1, { encoded })
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:mount()
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { encoded })
end

return M
