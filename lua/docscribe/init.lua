--- @module "docscribe.init"
---
--- This module is responsible for initializing the `docscribe.nvim` plugin.
---
--- It sets up user configurations, highlights, and custom Neovim commands
--- required for the plugin's functionality.

local config = require("docscribe.config")
local docscribe_generate = require("docscribe.commands.generate_docs").generate_docs_command

local M = {}

--- Sets up metadata, such as highlights, for the plugin.
---
--- Reads the user-configured highlight background color and applies it to
--- the `DocscribeProcessing` highlight group.
local function set_metadata()
    local highlight_color = config.get_config("ui").highlight.bg
    if highlight_color then
        vim.cmd("highlight DocscribeProcessing guibg=" .. highlight_color)
    end
end

--- Defines custom Neovim user commands for the plugin.
---
--- Creates the `:DocscribeGenerate` command, which triggers the documentation
--- generation process.
local function set_commands()
    vim.api.nvim_create_user_command("DocscribeGenerate", docscribe_generate, {})
end

--- Sets up the `docscribe.nvim` plugin.
---
--- This function initializes the plugin by applying user configurations,
--- setting up highlights, and registering commands.
---
--- @param user_config table: A table containing user-defined configuration
--- options for the plugin.
function M.setup(user_config)
    config.setup(user_config)
    set_metadata()
    set_commands()
end

return M
