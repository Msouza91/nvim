local M = {}

function M.opts()
	local opts = {
		enabled = true,
		actions = {
			trouble_open = function(...)
				return require("trouble.sources.snacks").actions.trouble_open.action(...)
			end,
		},
		sources = {
			select = {
				layout = {
					preset = "telescope",
				},
			},
		},
		win = {
			input = {
				keys = {
					["<a-t>"] = {
						"trouble_open",
						mode = { "n", "i" },
					},
				},
			},
		},
	}
	return opts
end

return M
