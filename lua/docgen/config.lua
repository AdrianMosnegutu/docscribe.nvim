local M = {}

local config = {
    ui = {
        highlight_color = "#545454",
    },
    runner = "ollama",
    model = "llama3.2",
    prompt_template = [[
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
}

--- Sets up the plugin configuration by merging user-provided values with defaults.
--- @param user_config table: A table containing user-defined configuration options.
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config)
end

--- Retrieves a value from the plugin configuration.
--- @param key string: The key corresponding to the configuration value to retrieve.
--- @return any: The value associated with the given key, or nil if it doesn't exist.
function M.get_config(key)
    return config[key]
end

return M
