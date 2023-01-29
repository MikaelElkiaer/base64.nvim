local M = {}
M.encode = function()
	local row1, col1 = unpack(vim.fn.getpos("v"), 2, 3)
	local row2, col2 = unpack(vim.api.nvim_win_get_cursor(0))
	local content = vim.api.nvim_buf_get_text(0, row1 - 1, col1 - 1, row2 - 1, col2 + 1, {})
	local text = table.concat(content, "\n")
	local decoded = vim.fn.system({ "base64", "--wrap", "0" }, text)
	decoded = string.gsub(decoded, "%s+", "")

	local Popup = require("nui.popup")
	local popup = Popup({
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
		},
		position = 1,
		relative = "cursor",
		size = {
			width = 1,
			height = 1,
		},
	})
	popup:mount()
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { decoded })
end

return M
