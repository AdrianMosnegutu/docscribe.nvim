local config = require("docgen.config")
local core = require("docgen.core")

local M = {}

function M.setup(user_config)
    config.setup(user_config)

    vim.api.nvim_create_user_command("DocGen", core.generate_docs_for_function_under_cursor, {})

    local highlight_color = config.get_config("ui").highlight_color
    if highlight_color then
        vim.cmd("highlight DocgenProcessing guibg=" .. highlight_color)
    end
end

return M
