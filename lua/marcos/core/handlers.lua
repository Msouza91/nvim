local M = {}
function M.azure()
	local opts = {
		settings = {
			yaml = {
				schemas = {
					["~/Downloads/Pipelines/service-schema.json"] = {
						"azure-pipeline*.y*l",
						"*.azure*",
						"Azure-Pipelines/**/*.y*l",
						"Pipelines/*.y*l",
						"ADO/**/*.y*l",
						"ADO/*.y*l",
					},
				},
			},
		},
	}
	return opts
end
function M.yaml()
	local opts = {
		filetypes = {},
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemaStore = {
				enable = true,
				url = "",
			},
			schemas = require("schemastore").yaml.schemas({
				replace = {
					["Markdownlint"] = {
						description = "Markdownlint overridden",
						fileMatch = ".markdownlint.y*l",
						name = "Markdownlint",
						url = "https://raw.githubusercontent.com/DavidAnson/markdownlint/main/schema/markdownlint-config-schema.json",
					},
					["Azure Pipelines"] = {
						description = "Azure Pipelines overridden",
						fileMatch = {
							"azure-pipeline*.y*l",
							"tasks/**/*.y*l",
							"jobs/*.y*l",
							"stages/*.y*l",
							"pipelines/*.y*l",
						},
						name = "Azure Pipelines",
						url = "~/Downloads/stages/service-schema.json",
					},
				},
				ignore = {
					-- "Azure Pipelines",
					-- "Markdownlint",
				},
			}),
			validate = { enable = true },
			completion = { enable = true },
			editor = {
				tabSize = 2,
			},
		},
	}
	return opts
end
return M
