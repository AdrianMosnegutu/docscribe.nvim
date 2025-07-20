--- @module "docscribe.llm.providers.groq"
--- Interface to the Groq LLM provider.

local Job = require("plenary.job")

local M = {}

--- Handles the exit of the curl job for the Groq provider.
--- @param job table The job object.
--- @param code number The exit code.
--- @param callback fun(docs: string|nil, err_msg: string|nil) The callback function.
local function handle_job_exit(job, code, callback)
    if code ~= 0 then
        local error_message = table.concat(job:stderr_result(), "")
        callback(nil, "Error generating Groq response: " .. error_message)
        return
    end

    local result = table.concat(job:result(), "")
    local ok, data = pcall(vim.json.decode, result)

    if not ok then
        callback(nil, "Failed to decode Groq API response: " .. tostring(data))
        return
    end

    if data.error then
        callback(nil, "Groq API error: " .. data.error.message)
        return
    end

    if data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content then
        callback(data.choices[1].message.content)
    else
        callback(nil, "Could not extract text from Groq API response")
    end
end

--- Generates a response using the Groq LLM provider.
--- @param prompt string The prompt to send to Groq.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with the response or an error.
--- @param opts table The options for the Groq provider. Must contain `model` and `api_key`.
function M.generate_response(prompt, callback, opts)
    if not opts.api_key or opts.api_key == "" then
        callback(nil, "Groq API key is not configured. Set the GROQ_API_KEY environment variable.")
        return
    end

    local url = "https://api.groq.com/openai/v1/chat/completions"

    local body = {
        model = opts.model,
        messages = {
            {
                role = "user",
                content = prompt,
            },
        },
    }

    Job:new({
        command = "curl",
        args = {
            "-X",
            "POST",
            "-H",
            "Content-Type: application/json",
            "-H",
            "Authorization: Bearer " .. opts.api_key,
            url,
            "-d",
            vim.json.encode(body),
        },
        on_exit = function(job, code)
            handle_job_exit(job, code, callback)
        end,
    }):start()
end

return M

