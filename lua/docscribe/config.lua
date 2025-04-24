local M = {}

local config = {
	ui = {
		highlight = {
			style = "signature",        -- "signature" | "full" | "none" function highlight
			timeout = 2000,             -- Time (ms) before highlight fades
			bg = "#545454",           -- Highlight background color
		},
	},
	llm = {
		provider = "ollama",            -- Backend used for LLM (e.g., ollama, openai)
		model = "llama3.2",             -- Default model used for docs
	},
	-- All prompt templates must include `{{code}}` as the function code placeholder!
	prompts = {
		-- Default prompt used to generate TSDoc comments.
		default_prompt_template = [[
            You are a documentation assistant.

            Generate a **TypeScript TSDoc** comment block for the function below. The output must:

            1. Start with `/**` and end with `*/` (pure TSDoc format).
            2. Include a **clear and concise function description**.
            3. Document **each parameter** with `@param`, describing the name, type, and purpose.
            4. Include a `@returns` tag with a description of the return value.
            5. If the function throws any exceptions, include a `@throws` tag for each.
            6. Include a `@example` block showing one or two typical usages.

            **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
            Do **not** include the function code in your output.
            Just return the unwrapped TSDoc block as plain text.

            ```typescript
            {{code}}
            ```
        ]],
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
