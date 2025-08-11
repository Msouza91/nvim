local M = {}

local git_worktree = require("git-worktree")

-- Helper function to get git worktree list
local function get_worktrees()
	local handle = io.popen("git worktree list")
	if not handle then
		vim.notify("Failed to run git worktree list", vim.log.levels.ERROR)
		return {}
	end

	local result = handle:read("*a")
	handle:close()

	local results = {}
	for line in result:gmatch("[^\r\n]+") do
		local fields = vim.split(vim.trim(line):gsub("%s+", " "), " ")
		local entry = {
			path = fields[1],
			sha = fields[2],
			branch = fields[3],
		}

		if entry.sha ~= "(bare)" and entry.path then
			table.insert(results, {
				text = entry.branch or vim.fn.fnamemodify(entry.path, ":t"),
				file = entry.path,
				path = entry.path,
				sha = entry.sha,
				branch = entry.branch,
				-- Add current marker for sorting
				current = entry.branch and vim.fn.getcwd():find(vim.fn.fnamemodify(entry.path, ":p"), 1, true) == 1,
			})
		end
	end

	return results
end

-- Helper function to get git branches
local function get_git_branches()
	local handle = io.popen("git branch -a --format='%(refname:short)'")
	if not handle then
		vim.notify("Failed to get git branches", vim.log.levels.ERROR)
		return {}
	end

	local result = handle:read("*a")
	handle:close()

	local branches = {}
	local seen = {}

	for line in result:gmatch("[^\r\n]+") do
		local branch = vim.trim(line)
		-- Skip HEAD and empty lines
		if not branch:match("^HEAD") and branch ~= "" then
			-- Clean up remote branch names and current branch marker
			local clean_branch = branch:gsub("^%*%s*", ""):gsub("^origin/", "")

			-- Only add unique branches
			if not seen[clean_branch] and clean_branch ~= "" then
				seen[clean_branch] = true
				table.insert(branches, {
					text = clean_branch,
					branch = clean_branch,
					is_remote = branch:match("^origin/") ~= nil,
					is_current = branch:match("^%*") ~= nil,
				})
			end
		end
	end

	return branches
end

-- Helper function to get git log for preview
local function get_git_log(path, count)
	local handle =
		io.popen(string.format("git -C %s log --oneline -%d 2>/dev/null", vim.fn.shellescape(path), count or 10))
	if not handle then
		return {}
	end

	local result = handle:read("*a")
	handle:close()

	local lines = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(lines, "  " .. line)
	end

	return lines
end

-- Main worktrees picker
function M.git_worktrees()
	local items = get_worktrees()

	if #items == 0 then
		vim.notify("No git worktrees found", vim.log.levels.WARN)
		return
	end

	Snacks.picker.pick({
		source = "git_worktrees",
		title = "Git Worktrees",
		items = items,
		format = function(item)
			local highlights = {}

			-- Branch name with current marker
			if item.current then
				table.insert(highlights, { "● " .. (item.branch or ""), "DiagnosticOk" })
			else
				table.insert(highlights, { "  " .. (item.branch or ""), "TelescopeResultsIdentifier" })
			end

			-- Path
			table.insert(highlights, { "  " })
			table.insert(highlights, { vim.fn.fnamemodify(item.path, ":~"), "Comment" })

			-- SHA
			if item.sha then
				table.insert(highlights, { "  " })
				table.insert(highlights, { item.sha:sub(1, 8), "Number" })
			end

			return highlights
		end,
		preview = function(ctx)
			if not ctx.item or not ctx.item.path then
				return false
			end

			local lines = {
				"Git Worktree Information",
				"========================",
				"",
				"Branch: " .. (ctx.item.branch or "unknown"),
				"Path: " .. ctx.item.path,
				"SHA: " .. (ctx.item.sha or "unknown"),
				"",
				"Recent commits:",
				"---------------",
			}

			-- Add recent commits
			local log_lines = get_git_log(ctx.item.path, 15)
			for _, line in ipairs(log_lines) do
				table.insert(lines, line)
			end

			vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
			vim.bo[ctx.buf].filetype = "gitlog"
			return true
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.path then
				vim.notify("Switching to worktree: " .. (item.branch or item.path))
				git_worktree.switch_worktree(item.path)
			end
		end,
		sort = {
			fields = { "current:desc", "branch" },
		},
		win = {
			input = {
				keys = {
					["<c-d>"] = {
						function(picker)
							local item = picker:current()
							if not item then
								return
							end

							local branch_name = item.branch or vim.fn.fnamemodify(item.path, ":t")
							local choice = vim.fn.input("Delete worktree '" .. branch_name .. "'? [y/N]: ")

							if choice:lower() == "y" then
								picker:close()
								vim.notify("Deleting worktree: " .. branch_name)
								git_worktree.delete_worktree(item.path, false, {
									on_success = function()
										vim.notify(
											"Successfully deleted worktree: " .. branch_name,
											vim.log.levels.INFO
										)
									end,
									on_failure = function()
										vim.notify("Failed to delete worktree: " .. branch_name, vim.log.levels.ERROR)
									end,
								})
							end
						end,
						mode = { "n", "i" },
						desc = "Delete worktree",
					},
					["<c-f>"] = {
						function(picker)
							local item = picker:current()
							if not item then
								return
							end

							local branch_name = item.branch or vim.fn.fnamemodify(item.path, ":t")
							local choice = vim.fn.input("Force delete worktree '" .. branch_name .. "'? [y/N]: ")

							if choice:lower() == "y" then
								picker:close()
								vim.notify("Force deleting worktree: " .. branch_name)
								git_worktree.delete_worktree(item.path, true, {
									on_success = function()
										vim.notify(
											"Successfully force deleted worktree: " .. branch_name,
											vim.log.levels.INFO
										)
									end,
									on_failure = function()
										vim.notify(
											"Failed to force delete worktree: " .. branch_name,
											vim.log.levels.ERROR
										)
									end,
								})
							end
						end,
						mode = { "n", "i" },
						desc = "Force delete worktree",
					},
				},
			},
			list = {
				keys = {
					["dd"] = {
						function(picker)
							local item = picker:current()
							if not item then
								return
							end

							local branch_name = item.branch or vim.fn.fnamemodify(item.path, ":t")
							local choice = vim.fn.input("Delete worktree '" .. branch_name .. "'? [y/N]: ")

							if choice:lower() == "y" then
								picker:close()
								git_worktree.delete_worktree(item.path)
							end
						end,
						desc = "Delete worktree",
					},
				},
			},
		},
		layout = {
			preset = "default",
		},
	})
end

-- Create worktree picker
function M.create_git_worktree()
	local branches = get_git_branches()

	if #branches == 0 then
		vim.notify("No branches found", vim.log.levels.WARN)
		return
	end

	Snacks.picker.pick({
		source = "git_branches_create",
		title = "Select Branch for New Worktree",
		items = branches,
		format = function(item)
			local highlights = {}

			if item.is_current then
				table.insert(highlights, { "● " .. item.branch, "DiagnosticOk" })
			elseif item.is_remote then
				table.insert(highlights, { "  " .. item.branch, "DiagnosticInfo" })
			else
				table.insert(highlights, { "  " .. item.branch, "String" })
			end

			return highlights
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.branch then
				local branch = item.branch

				-- Prompt for worktree path
				vim.schedule(function()
					-- Default to trees directory with sanitized branch name
					local sanitized_branch = branch:gsub("[^%w%-_/]", "-"):gsub("/", "-")
					local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
					local default_path = git_root .. "/trees/" .. sanitized_branch

					local path = vim.fn.input({
						prompt = "Path for worktree (" .. branch .. "): ",
						default = default_path,
						completion = "file",
					})

					if path and path ~= "" then
						-- Create trees directory if it doesn't exist
						local trees_dir = vim.fn.fnamemodify(path, ":h")
						if vim.fn.isdirectory(trees_dir) == 0 then
							vim.fn.mkdir(trees_dir, "p")
							vim.notify("Created directory: " .. trees_dir)
						end

						vim.notify("Creating worktree: " .. branch .. " at " .. path)

						-- Use the clean branch name for git worktree command
						git_worktree.create_worktree(path, branch, "origin")
					end
				end)
			end
		end,
		win = {
			input = {
				keys = {
					["<c-n>"] = {
						function(picker)
							picker:close()
							vim.schedule(function()
								M.create_new_branch_worktree()
							end)
						end,
						mode = { "n", "i" },
						desc = "Create new branch and worktree",
					},
				},
			},
		},
		layout = {
			preset = "default",
		},
	})
end

-- Create new branch and worktree
function M.create_new_branch_worktree()
	vim.schedule(function()
		local branch_name = vim.fn.input("New branch name: ")
		if branch_name and branch_name ~= "" then
			local sanitized_branch = branch_name:gsub("[^%w%-_/]", "-"):gsub("/", "-")
			local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
			local default_path = git_root .. "/trees/" .. sanitized_branch

			local path = vim.fn.input({
				prompt = "Path for worktree (" .. branch_name .. "): ",
				default = default_path,
				completion = "file",
			})

			if path and path ~= "" then
				-- Create trees directory if it doesn't exist
				local trees_dir = vim.fn.fnamemodify(path, ":h")
				if vim.fn.isdirectory(trees_dir) == 0 then
					vim.fn.mkdir(trees_dir, "p")
					vim.notify("Created directory: " .. trees_dir)
				end

				vim.notify("Creating new branch and worktree: " .. branch_name .. " at " .. path)
				git_worktree.create_worktree(path, branch_name, "origin")
			end
		end
	end)
end

-- Hook into git-worktree events
local Worktree = require("git-worktree")

-- Refresh file explorer on worktree change
Worktree.on_tree_change(function(op, metadata)
	if op == Worktree.Operations.Switch then
		vim.notify(
			"Switched from "
				.. vim.fn.fnamemodify(metadata.prev_path, ":t")
				.. " to "
				.. vim.fn.fnamemodify(metadata.path, ":t"),
			vim.log.levels.INFO
		)

		-- Refresh any open file explorers
		vim.schedule(function()
			-- Refresh neo-tree if it's available and loaded
			local neotree_ok, neotree = pcall(require, "neo-tree.command")
			if neotree_ok and neotree then
				pcall(neotree.execute, { action = "refresh" })
			end

			-- Refresh oil.nvim if it's available and loaded
			local oil_ok, oil = pcall(require, "oil")
			if oil_ok and oil then
				-- Check if oil has refresh function, otherwise try setup
				if type(oil.refresh) == "function" then
					pcall(oil.refresh)
				elseif type(oil.setup) == "function" then
					-- Oil might refresh automatically on cwd change
					-- Just trigger a redraw
					vim.cmd("redraw")
				end
			end

			-- Alternative: just refresh all windows/buffers
			vim.cmd("checktime")
		end)
	elseif op == Worktree.Operations.Create then
		vim.notify(
			"Created worktree: " .. metadata.branch .. " at " .. vim.fn.fnamemodify(metadata.path, ":t"),
			vim.log.levels.INFO
		)
	elseif op == Worktree.Operations.Delete then
		vim.notify("Deleted worktree at " .. vim.fn.fnamemodify(metadata.path, ":t"), vim.log.levels.INFO)
	end
end)

return M

