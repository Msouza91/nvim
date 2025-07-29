---------- UTILS ----------
local M = {}

---@class TermConfig
---@field direction "new" | "vnew" | "tabnew"
---@field cmd string
---@field new? boolean
---@field focus boolean
---@param opts TermConfig

function M.term(opts, ...)
	local terminal = vim.iter(vim.fn.getwininfo()):find(function(v)
		return v.terminal == 1
	end)
	if terminal and not opts.new then
		vim.api.nvim_buf_call(terminal.bufnr, function()
			vim.cmd("$")
		end)
		return vim.api.nvim_chan_send(vim.b[terminal.bufnr].terminal_job_id, string.format(opts.cmd .. "\n", ...))
	end

	local current_win = vim.api.nvim_get_current_win()
	local size = math.floor(vim.api.nvim_win_get_height(0) / 3)
	vim.cmd[opts.direction]({ range = opts.direction == "new" and { size } or { nil } })
	local term = vim.fn.termopen(vim.env.SHELL) --[[@as number]]
	if not opts.focus then
		vim.cmd.stopinsert()
		vim.api.nvim_set_current_win(current_win)
	end
	vim.api.nvim_chan_send(term, string.format(opts.cmd .. "\n", ...))
end

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

function M.toggleTerm()
	local terminal = vim.iter(vim.fn.getwininfo()):find(function(v)
		return v.terminal == 1
	end)
	if terminal then
		vim.api.nvim_win_close(terminal.winid, true)
	else
		M.term({ direction = "new", focus = true, cmd = "" })
	end
end

return M
