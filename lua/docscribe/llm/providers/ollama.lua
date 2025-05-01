--- @module "docscribe.llm.providers.ollama"
---
--- This module provides an interface to the Ollama LLM provider for generating
--- documentation responses based on input prompts.
---
--- It uses the `plenary.job` library to execute the `ollama` CLI command in a
--- background job, sending prompts and receiving model-generated outputs.
---
--- The module is designed to integrate seamlessly with the documentation generation
--- pipeline, enabling asynchronous generation via a callback mechanism.

local Job = require("plenary.job")

local M = {}

--- Generates a response using the Ollama LLM provider.
---
--- It uses a prompt template, sends it to the `ollama` process, and then invokes
--- the provided callback with the generated response.
---
--- If the `ollama` process fails, an error message is shown, and the callback is
--- called with `nil`.
---
--- @param prompt string The prompt to send to Ollama.
--- @param model string The name of the Ollama model to use.
--- @param callback fun(docs: string|nil, err_msg: string|nil) A callback function
--- that is called with the generated response or `nil` if there is an error.
function M.generate_response(prompt, model, callback)
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

return M
