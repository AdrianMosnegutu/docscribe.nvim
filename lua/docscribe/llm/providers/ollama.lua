--- @module "docscribe.llm.providers.ollama"
--- Interface to the Ollama LLM provider.

local Job = require("plenary.job")

local M = {}

--- Handles the exit of the Ollama job.
--- @param job table The job object.
--- @param code number The exit code.
--- @param callback fun(docs: string|nil, err_msg: string|nil) The callback function.
local function handle_job_exit(job, code, callback)
    if code ~= 0 then
        callback(nil, "Error generating Ollama response")
        return
    end

    local docs = table.concat(job:result(), "\n")
    callback(docs)
end

--- Generates a response using the Ollama LLM provider.
--- @param prompt string The prompt to send to Ollama.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with the response or an error.
--- @param opts table The Ollama model to use.
function M.generate_response(prompt, callback, opts)
    Job:new({
        command = "ollama",
        args = { "run", opts.model },
        writer = prompt,
        on_exit = function(job, code)
            handle_job_exit(job, code, callback)
        end,
    }):start()
end

return M
