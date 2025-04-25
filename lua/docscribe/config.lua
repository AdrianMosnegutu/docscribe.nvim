local default_template = require("docscribe.prompt_templates.default")
local c_template = require("docscribe.prompt_templates.c")
local cpp_template = require("docscribe.prompt_templates.cpp")
local python_template = require("docscribe.prompt_templates.python")
local java_template = require("docscribe.prompt_templates.java")
local lua_template = require("docscribe.prompt_templates.lua")
local javascript_template = require("docscribe.prompt_templates.javascript")
local typescript_template = require("docscribe.prompt_templates.typescript")

local M = {}

local config = {
	ui = {
		highlight = {
			style = "signature",        -- "signature" | "full" | "none" function highlight
			timeout = 2000,             -- Time (ms) before highlight fades
			bg = "#545454",             -- Highlight background color
		},
	},
	llm = {
		provider = "ollama",            -- Backend used for LLM (e.g., ollama, openai)
		model = "llama3.2",             -- Default model used for docs
	},
	prompt_templates = {                -- Set of prompt templates for each programming language
		default = default_template,
		h = c_template,
		c = c_template,
		hpp = cpp_template,
		cpp = cpp_template,
		python = python_template,
		java = java_template,
		lua = lua_template,
		javascript = javascript_template,
		javascriptreact = javascript_template,
		typescript = typescript_template,
		typescriptreact = typescript_template,
	},
}

--- Sets up the plugin configuration by merging user-provided values with defaults.
---
--- This function allows users to customize the plugin's behavior by passing in their own configuration.
--- The provided configuration is merged with the default settings, with user settings taking precedence.
---
--- @param user_config table A table containing user-defined configuration options. If not provided, the default config will be used.
---
--- @return nil
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config)
end

--- Retrieves a value from the plugin configuration.
---
--- This function allows you to access specific configuration values that have been set in the plugin.
--- If the provided key does not exist in the configuration, `nil` will be returned.
---
--- @param key string The key corresponding to the configuration value to retrieve.
---
--- @return any config_value The value associated with the given key, or nil if it doesn't exist.
function M.get_config(key)
	return config[key]
end

return M
