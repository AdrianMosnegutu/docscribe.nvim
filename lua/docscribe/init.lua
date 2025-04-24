local config = require("docscribe.config")
local commands = require("docscribe.core.commands")

local M = {}

function M.setup(user_config)
    config.setup(user_config)

    vim.api.nvim_create_user_command("DocscribeGenerate", commands.generate_docs_for_function_under_cursor, {})

    local highlight_color = config.get_config("ui").highlight_color
    if highlight_color then
        vim.cmd("highlight DocscribeProcessing guibg=" .. highlight_color)
    end
end

return M
