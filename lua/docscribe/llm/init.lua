--- @module "docscribe.llm"
---
--- Module for generating documentation using LLM providers, such as Ollama.
--- This module handles generating documentation for code snippets using a prompt
--- template based on the language of the code and the configured LLM provider.
---
--- It currently supports the Ollama LLM provider for generating docs.

local config = require("docscribe.config")
local ollama = require("docscribe.llm.providers.ollama")

local M = {}

--- Generates documentation for a given function code based on a configured prompt
--- template.
---
--- This function checks the current file's language, selects the appropriate prompt
--- template, and invokes the `generate_using_ollama` function if the configured LLM
--- provider is Ollama.
---
--- If the LLM provider is invalid, it shows an error message to the user.
---
--- @param function_code string The code of the function for which documentation is
--- to be generated.
--- @param callback fun(docs: string|nil, err_msg: string|nil) A callback function
--- that is called with the generated documentation or `nil` if there is an error.
function M.generate_docs(function_code, callback)
    local lang = vim.bo.filetype

    -- Build the prompt
    local prompt_templates = config.get_config("prompt_templates")
    local prompt_template = prompt_templates[lang] or prompt_templates.default
    local prompt = prompt_template:gsub("{{code}}", function_code)

    local llm = config.get_config("llm")

    -- Chose the configured llm provider and model
    if llm.provider == "ollama" then
        ollama.generate_response(prompt, llm.model, callback)
    else
        callback(nil, 'Invalid LLM runner "' .. llm.provider .. '"')
    end
end

return M
