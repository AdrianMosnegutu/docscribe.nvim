--- @module "docscribe.utils.llm"
---
--- Module for generating documentation using LLM providers, such as Ollama.
--- This module handles generating documentation for code snippets using a prompt
--- template based on the language of the code and the configured LLM provider.
---
--- It currently supports the Ollama LLM provider for generating docs.

local Job = require("plenary.job")
local config = require("docscribe.config")

local M = {}

--- Generates documentation using the Ollama LLM provider.
---
--- This function spawns an external `ollama` process to generate documentation
--- for the given code.
---
--- It uses a prompt template, sends it to the `ollama` process, and then invokes
--- the provided callback with the generated documentation.
---
--- If the `ollama` process fails, an error message is shown, and the callback is
--- called with `nil`.
---
--- @param prompt string The prompt (code with a template) to send to Ollama.
--- @param model string The name of the Ollama model to use.
--- @param callback fun(docs: string|nil, err_msg: string|nil) A callback function
--- that is called with the generated documentation or `nil` if there is an error.
local function generate_using_ollama(prompt, model, callback)
    --- @diagnostic disable-next-line: missing-fields
    Job:new({
        command = "ollama",
        args = { "run", model },
        writer = prompt,
        on_exit = function(job, code)
            if code == 0 then
                local docs = table.concat(job:result(), "\n")
                callback(docs)
            else
                callback(nil, "Error generating Ollama response")
            end
        end,
    }):start()
end

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

    local prompt_templates = config.get_config("prompt_templates")
    local prompt_template = prompt_templates[lang] or prompt_templates.default
    local prompt = prompt_template:gsub("{{code}}", function_code)

    local llm = config.get_config("llm")
    if llm.provider == "ollama" then
        generate_using_ollama(prompt, llm.model, callback)
    else
        callback(nil, 'Invalid LLM runner "' .. llm.provider .. '"')
    end
end

return M
