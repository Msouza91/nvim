-- Markdown filetype-specific configurations

-- Set keymap for toggling todos (only available in markdown files)
vim.keymap.set("n", "<leader>mt", function()
	require("marcos.utils").toggle_markdown_todo()
end, { desc = "Toggle markdown todo", buffer = true })

