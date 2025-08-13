return {
	"EdenEast/nightfox.nvim",
	name = "nightfox",
	lazy = false,
	config = function()
		local opts = {
			styles = {
				comments = "italic",
				functions = "italic,bold",
			},
		}
		require("nightfox").setup(opts)
		vim.cmd("colorscheme terafox")
		--vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		--vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	end,
}
