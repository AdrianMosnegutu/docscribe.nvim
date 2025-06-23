--- @module "docscribe.init"
--- Initializes the `docscribe.nvim` plugin.

local config = require("docscribe.config")
local docscribe_generate = require("docscribe.commands.generate_docs").generate_docs_command

local M = {}

--- Sets up plugin metadata.
local function set_metadata()
    local highlight_color = config.get_config("ui").highlight.bg
    if highlight_color then
        vim.cmd("highlight DocscribeProcessing guibg=" .. highlight_color)
    end
end

--- Defines custom Neovim commands.
local function set_commands()
    vim.api.nvim_create_user_command("DocscribeGenerate", docscribe_generate, {})
end

--- Sets up the `docscribe.nvim` plugin.
--- @param user_config table: User-defined configuration options.
function M.setup(user_config)
    config.setup(user_config)
    set_metadata()
    set_commands()
end

return M
