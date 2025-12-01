return {
	"p00f/alabaster.nvim",
	name = "alabaster",
	lazy = false,
	config = function()
		vim.o.background = "dark"
		vim.cmd("colorscheme alabaster")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	end,
}
