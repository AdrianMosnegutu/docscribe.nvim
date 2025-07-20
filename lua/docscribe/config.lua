--- @module "docscribe.config"
--- Handles global configuration for `docscribe.nvim`.

local prompt_templates = require("docscribe.prompt_templates")

--- Default configuration.
local config = {
    ui = {
        highlight = {
            style = "signature", -- "signature" | "full" | "none" function highlight
            timeout = 2000,      -- Time (ms) before highlight fades
            bg = "#545454",      -- Highlight background color
        },
    },
    llm = {
        provider = "ollama", -- Backend used for LLM (e.g., ollama, google)
        provider_opts = {
            ollama = {
                model = "llama3.2", -- Default model used for docs
            },
            google = {
                model = "gemini-1.5-flash",
                api_key = os.getenv("GOOGLE_API_KEY"), -- API key for Google's Gemini
            },
        },
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

--- Sets up user configuration.
--- @param user_config table User-specified configuration overrides.
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config)
end

--- Retrieves a configuration section by key.
--- @param key string The top-level key to retrieve from the configuration.
--- @return any value The value corresponding to the key.
function M.get_config(key)
    return config[key]
end

return M
