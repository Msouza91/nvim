return {
	"https://codeberg.org/alessandromartini/git-worktree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
	config = function()
		require("git-worktree").setup({
			change_directory_command = "cd",
			update_on_change = true,
			update_on_change_command = "silent! bufdo! checktime | e .",
			clearjumps_on_change = true,
			autopush = false,
		})

		-- Load snacks integration
		require("marcos.extra.snacks-git-worktree")
	end,
	keys = {
		{
			"<leader>gt",
			function()
				require("marcos.extra.snacks-git-worktree").git_worktrees()
			end,
			desc = "Git Worktrees",
		},
		{
			"<leader>gT",
			function()
				require("marcos.extra.snacks-git-worktree").create_git_worktree()
			end,
			desc = "Create Git Worktree",
		},
		{
			"<leader>gN",
			function()
				require("marcos.extra.snacks-git-worktree").create_new_branch_worktree()
			end,
			desc = "Create New Branch & Worktree",
		},
	},
}
