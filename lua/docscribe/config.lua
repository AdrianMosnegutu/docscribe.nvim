--- @module "docscribe.config"
---
--- Configuration module for Docscribe.
--- Handles global configuration settings like UI options, LLM provider settings,
--- and language-specific prompt templates.
---
--- Provides functions to setup user-provided configuration overrides
--- and to retrieve configuration values during runtime.

local prompt_templates = require("docscribe.prompt_templates")

-- Default configuration table.
-- Users can override parts of this configuration using `M.setup(user_config)`.
local config = {
    ui = {
        highlight = {
            style = "signature", -- "signature" | "full" | "none" function highlight
            timeout = 2000, -- Time (ms) before highlight fades
            bg = "#545454", -- Highlight background color
        },
    },
    llm = {
        provider = "ollama", -- Backend used for LLM (e.g., ollama, openai)
        model = "llama3.2", -- Default model used for docs
    },
    prompt_templates = { -- Set of prompt templates for each programming language
        default = prompt_templates.default_template,
        h = prompt_templates.c_template,
        c = prompt_templates.c_template,
        hpp = prompt_templates.cpp_template,
        cpp = prompt_templates.cpp_template,
        python = prompt_templates.python_template,
        java = prompt_templates.java_template,
        lua = prompt_templates.lua_template,
        javascript = prompt_templates.javascript_template,
        javascriptreact = prompt_templates.javascript_template,
        typescript = prompt_templates.typescript_template,
        typescriptreact = prompt_templates.typescript_template,
    },
}

local M = {}

--- Sets up user configuration by deep-merging it into the default config.
--- This allows users to customize only the parts they care about, without
--- redefining everything.
---
--- @param user_config table A table containing user-specified configuration
--- overrides.
---
--- Example usage:
--- ```lua
--- require("docscribe").setup({
---   llm = {
---     provider = "ollama",
---     model = "llama3.2",
---   },
---   ui = {
---     highlight = {
---       style = "full",
---       bg = "#123456",
---     },
---   },
--- })
--- ```
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config)
end

--- Retrieves a configuration section by key.
--- Useful for modules that need to access the current runtime configuration.
---
--- @param key string The top-level key to retrieve from the configuration
--- table (e.g., "llm", "ui", "prompt_templates").
--- @return any Returns the value corresponding to the provided key, or nil
--- if the key does not exist.
function M.get_config(key)
    return config[key]
end

return M
