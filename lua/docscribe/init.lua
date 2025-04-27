local config = require("docscribe.config")
local docscribe_generate = require("docscribe.commands.generate_docs").generate_docs_command

local M = {}

local function set_metadata()
    local highlight_color = config.get_config("ui").highlight.bg
    if highlight_color then
        vim.cmd("highlight DocscribeProcessing guibg=" .. highlight_color)
    end
end

local function set_commands()
    vim.api.nvim_create_user_command("DocscribeGenerate", docscribe_generate, {})
end

function M.setup(user_config)
    config.setup(user_config)
    set_metadata()
    set_commands()
end

return M
