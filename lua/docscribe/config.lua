local prompt_templates = require("docscribe.prompt_templates")

local M = {}

local config = {
	ui = {
		highlight = {
			style = "signature",            -- "signature" | "full" | "none" function highlight
			timeout = 2000,                 -- Time (ms) before highlight fades
			bg = "#545454",                 -- Highlight background color
		},
	},
	llm = {
		provider = "ollama",                -- Backend used for LLM (e.g., ollama, openai)
		model = "llama3.2",                 -- Default model used for docs
	},
	prompt_templates = {                    -- Set of prompt templates for each programming language
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

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config)
end

function M.get_config(key)
	return config[key]
end

return M
