local M = {}

local get_selection = function()
	local x1, y1 = unpack(vim.fn.getpos("v"), 2, 3)
	local x2, y2 = unpack(vim.api.nvim_win_get_cursor(0))
	local text_lines = vim.api.nvim_buf_get_text(0, x1 - 1, y1 - 1, x2 - 1, y2 + 1, {})
	local text = table.concat(text_lines, "\n")

	return text, x1, y1, x2, y2
end

local call_base64 = function(text, ...)
	local text_decoded = vim.fn.system({ "base64", unpack(...) }, text):gsub("%s+", "")
	local exit_code = vim.v.shell_error
	local ok = exit_code == 0

	return ok, text_decoded
end

local create_popup = function(title)
	local Popup = require("nui.popup")
	local popup = Popup({
		border = {
			padding = { 1, 1 },
			style = "rounded",
			text = {
				bottom = "Insert [e]ncoded, [d]ecoded, or [q]uit",
				bottom_align = "right",
				top = title,
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
			height = 2,
		},
		win_options = {
			winhighlight = "Normal:Normal",
		},
	})

	popup:map("n", "q", function(_)
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)

	return popup
end

M.decode = function()
	local text, x1, y1, x2, y2 = get_selection()
	local ok, text_decoded = call_base64(text, { "--decode" })
	if not ok then
		vim.notify("Base64 decoding failed", vim.log.levels.WARN)
		return
	end

	local parent_buf = vim.api.nvim_get_current_buf()
	local popup = create_popup("Base64 decode:")
	popup:map("n", "e", function(_)
		local text_updated = vim.api.nvim_buf_get_text(popup.bufnr, 0, 0, -1, -1, {})
		local text_encoded = vim.fn.system({ "base64", "--wrap", "0" }, text_updated)
		vim.api.nvim_buf_set_text(parent_buf, x1 - 1, y1 - 1, x2 - 1, y2 + 1, { text_encoded })
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:map("n", "d", function(_)
		local text_updated = vim.api.nvim_buf_get_text(popup.bufnr, 0, 0, -1, -1, {})
		vim.api.nvim_buf_set_text(parent_buf, x1 - 1, y1 - 1, x2 - 1, y2 + 1, text_updated)
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:mount()

	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { text_decoded })
end

M.encode = function()
	local text, x1, y1, x2, y2 = get_selection()
	local ok, text_encoded = call_base64(text, { "--wrap", "0" })
	if not ok then
		vim.notify("Base64 encoding failed", vim.log.levels.WARN)
		return
	end

	local parent_buf = vim.api.nvim_get_current_buf()
	local popup = create_popup("Base64 encode:")
	popup:map("n", "e", function(_)
		vim.api.nvim_buf_set_text(parent_buf, x1 - 1, y1 - 1, x2 - 1, y2 + 1, { text_encoded })
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:map("n", "d", function(_)
		vim.api.nvim_buf_delete(popup.bufnr, {})
	end)
	popup:mount()

	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { text_encoded })
end

return M
