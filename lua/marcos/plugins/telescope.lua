return {
	"nvim-telescope/telescope.nvim",
	event = "VeryLazy",
	version = "0.1.6", -- or, branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		--Extensions
		"xiyaowong/telescope-emoji.nvim",
		--{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<leader>e", "<cmd>Telescope emoji<CR>", {})
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
		local opts = {
			defaults = {
				prompt_prefix = "🔍",
			},
			extensions = {
				"fzf",
				"emoji",
			},
		}
		require("telescope").setup(opts)
		require("marcos.telescope.multigrep").setup()
	end,
}
