return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		-- refer to `:h file-pattern` for more examples
		"BufReadPre "
			.. vim.fn.expand("~")
			.. "/vaults/Deez-notes/*.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/vaults/Deez-notes/*.md",
	},
	config = function()
		local opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "personal",
					path = "~/vaults/Deez-notes",
				},
				-- {
				-- 	name = "work",
				-- 	path = "~/vaults/work",
				-- },
			},
			daily_notes = {
				-- Optional, if you keep daily notes in a separate directory.
				folder = "Daily-notes",
				-- Optional, if you want to change the date format for the ID of daily notes.
				date_format = "%d-%m-%y",
				-- Optional, if you want to change the date format of the default alias of daily notes.
				alias_format = "%B %-d, %Y",
				-- Optional, default tags to add to each new daily note created.
				default_tags = { "daily", "daily-notes" },
				-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
				template = "daily.md",
				-- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
				workdays_only = true,
			},
			preferred_link_style = "markdown",
			completion = {
				-- Enables completion using nvim_cmp
				nvim_cmp = false,
				-- Enables completion using blink.cmp
				blink = true,
				-- Trigger completion at 2 chars.
				min_chars = 2,
				-- Set to false to disable new note creation in the picker
				create_new = true,
			},

			picker = {
				-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
				name = "snacks.pick",
				-- Optional, configure key mappings for the picker. These are the defaults.
				-- Not all pickers support all mappings.
				note_mappings = {
					-- Create a new note from your query.
					new = "<C-x>",
					-- Insert a link to the selected note.
					insert_link = "<C-l>",
				},
				tag_mappings = {
					-- Add tag(s) to current note.
					tag_note = "<C-x>",
					-- Insert a tag at the current location.
					insert_tag = "<C-l>",
				},
			},

			templates = {
				folder = "Templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
				-- A map for custom variables, the key should be the variable and the value a function.
				-- Functions are called with obsidian.TemplateContext objects as their sole parameter.
				-- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#substitutions
				substitutions = {},

				-- A map for configuring unique directories and paths for specific templates
				--- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#customizations
				customizations = {},
			},
			ui = { enable = false },
		}

		require("obsidian").setup(opts)

		-- Key mappings
		local mappings = {
			{ "<leader>oc", "<cmd>Obsidian check<cr>", "Obsidian Todo" },
			{ "<leader>os", "<cmd>Obsidian search<cr>", "Obsidian Search" },
			{ "<leader>ost", "<cmd>Obsidian tags<cr>", "Obsidian Search Tag Instances" },
			{ "<leader>oit", "<cmd>Obsidian template<cr>", "Obsidian insert template" },
			{ "<leader>ot", "<cmd>Obsidian today<cr>", "Obsidian Today Daily Note" },
			{ "<leader>oT", "<cmd>Obsidian tomorrow<cr>", "Obsidian Tomorrow Daily Note" },
			{ "<leader>oy", "<cmd>Obsidian yesterday<cr>", "Obsidian Yesterday Daily Note" },
			{ "<leader>on", "<cmd>Obsidian new<cr>", "Obsidian New Note" },
			{ "<leader>oN", "<cmd>Obsidian new_from_template<cr>", "Obsidian New Note From Template" },
			{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Obsidian Backlinks on Picker" },
		}

		for _, map in ipairs(mappings) do
			local mode = map.mode or "n"
			vim.keymap.set(mode, map[1], map[2], { desc = map[3], noremap = true, silent = true })
		end
	end,
}
