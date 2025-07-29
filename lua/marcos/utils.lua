---------- UTILS ----------
local M = {}

local runner = {
	python = "python3 $file",
	c = "gcc $file -o $output && ./$output; rm $output",
	javascript = "node $file",
	typescript = "ts-node $file",
	rust = function()
		local command = "rustc $file && ./$output; rm $output"
		local match = vim.system({ "cargo", "verify-project" }):wait().stdout:match('{"success":"true"}')
		return match and "cargo run" or command
	end,
	go = function()
		local command = "go run $file"
		local dir = vim.fs.dirname(vim.fs.find("go.mod", { upward = true })[1])
		return dir and "go run " .. dir or command
	end,
	sh = "sh $file",
}

-- Save and execute file based on filetype
function M.save_and_exec()
	local ft = vim.bo.filetype
	vim.cmd.write({ mods = { emsg_silent = true, noautocmd = true } })
	vim.api.nvim_echo({ { "Executing file" } }, false, {})
	if ft == "vim" or ft == "lua" then
		vim.cmd.source("%")
	else
		local file = vim.api.nvim_buf_get_name(0)
		vim.cmd.lcd(vim.fs.dirname(file))
		local command = type(runner[ft]) == "function" and runner[ft]() or runner[ft]
		if not command then
			return vim.notify(
				string.format("No config found for %s", ft),
				vim.log.levels.INFO,
				{ title = "Save and exec" }
			)
		end

		local output = vim.fn.fnamemodify(file, ":t:r") --[[@as string]]
		command = command:gsub("$file", file):gsub("$output", output)
		M.term({ direction = "new", focus = false, cmd = command })
	end
end

--Insert, check or uncheck a to-do in markdown files
function M.toggle_markdown_todo()
	local line = vim.api.nvim_get_current_line() or ""
	if line:match("^%s*%- %[%s*%]") then
		local new_line = line:gsub("^(%s*%-) %[%s*%]", "%1 [x]", 1)
		vim.api.nvim_set_current_line(new_line)
	elseif line:match("^%s*%- %[%s*x%s*%]") then
		local new_line = line:gsub("^(%s*%-) %[%s*x%s*%]", "%1 [ ]", 1)
		vim.api.nvim_set_current_line(new_line)
	else
		vim.api.nvim_set_current_line("- [ ] " .. line)
	end
end

return M
