--- @module "docscribe.llm.providers.ollama"
--- Interface to the Ollama LLM provider.

local Job = require("plenary.job")

local M = {}

--- Generates a response using the Ollama LLM provider.
--- @param prompt string The prompt to send to Ollama.
--- @param model string The Ollama model to use.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with the response or an error.
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
