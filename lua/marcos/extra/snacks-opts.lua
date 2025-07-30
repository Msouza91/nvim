local M = {}

function M.dashboard()
	return require("marcos.extra.snacks-dash").opts()
end

function M.picker()
	return require("marcos.extra.snacks-picker").opts()
end

-- function M.notifier()
--   return require("marcos.extra.snacks-notifier").opts()
-- end

return M
