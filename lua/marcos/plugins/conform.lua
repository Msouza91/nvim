return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				--yaml = { "prettier" },
				markdown = { "prettier" },
				json = { "prettier" },
				go = { "gofumpt" },
				nix = { "nixpkgs-fmt" },
				hcl = { "packer_fmt" },
				-- Use the "_" filetype to run formatters on filetypes that don't
				-- have other formatters configured.
				["_"] = { "trim_whitespace" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 5000,
				lsp_fallback = true,
			},
		}
		conform.setup(opts)
	end,
}
