local config = require("docgen.config")

local M = {}

function M.setup(user_config)
    config.setup(user_config)

    vim.notify(config.get_config("runner"), vim.log.levels.INFO)
    vim.notify(config.get_config("model"), vim.log.levels.INFO)
    vim.notify(config.get_config("prompt_template"), vim.log.levels.INFO)
end

return M
