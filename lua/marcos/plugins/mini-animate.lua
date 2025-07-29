return {
	"echasnovski/mini.animate",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local opts = {
			cursor = { enable = false },
		}
		require("mini.animate").setup(opts)
	end,
}
