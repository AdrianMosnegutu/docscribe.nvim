--- @module "docscribe.llm"
--- Generates documentation using LLM providers.

local config = require("docscribe.config")
local ollama = require("docscribe.llm.providers.ollama")

local M = {}

--- Generates documentation for a function using a configured prompt template.
--- @param function_code string The function code to document.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with generated docs or an error.
function M.generate_docs(function_code, callback)
    local lang = vim.bo.filetype

    local prompt_templates = config.get_config("prompt_templates")
    local prompt_template = prompt_templates[lang] or prompt_templates.default
    local prompt = prompt_template:gsub("{{code}}", function_code)

    local llm = config.get_config("llm")

    if llm.provider == "ollama" then
        ollama.generate_response(prompt, llm.model, callback)
    else
        callback(nil, 'Invalid LLM runner "' .. llm.provider .. '"')
    end
end

return M
