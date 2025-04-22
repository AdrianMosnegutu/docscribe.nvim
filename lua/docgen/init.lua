local config = require("docgen.config")
local core = require("docgen.core")

local M = {}

function M.setup(user_config)
	config.setup(user_config)

	vim.api.nvim_create_user_command("DocGen", core.generate, {})
end

return M
