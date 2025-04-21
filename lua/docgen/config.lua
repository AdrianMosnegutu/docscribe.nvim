local M = {}

local config = {
    runner = "ollama",
    model = "llama3.2",
    prompt_template = "Generate the docs for this function:\n\n%s",
}

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config)
end

function M.get_config(key)
    return config[key]
end

return M
