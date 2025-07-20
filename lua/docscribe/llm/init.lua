--- @module "docscribe.llm"
--- Generates documentation using LLM providers.

local config = require("docscribe.config")

local providers = {
    ollama = require("docscribe.llm.providers.ollama"),
    google = require("docscribe.llm.providers.google"),
}

local M = {}

--- Generates documentation for a function using a configured prompt template.
--- @param function_code string The function code to document.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with generated docs or an error.
function M.generate_docs(function_code, callback)
    local lang = vim.bo.filetype

    local prompt_templates = config.get_config("prompt_templates")
    local prompt_template = prompt_templates[lang] or prompt_templates.default
    local prompt = prompt_template:gsub("{{code}}", function_code)

    local llm_config = config.get_config("llm")
    local provider_name = llm_config.provider
    local provider_opts = llm_config.provider_opts[provider_name]

    local provider = providers[provider_name]

    if provider then
        provider.generate_response(prompt, callback, provider_opts)
    else
        callback(nil, 'Invalid LLM provider "' .. provider_name .. '"')
    end
end

return M
