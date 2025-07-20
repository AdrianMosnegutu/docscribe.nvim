--- @module "docscribe.llm.providers.google"
--- Interface to the Google LLM provider.

local Job = require("plenary.job")

local M = {}

--- Handles the exit of the curl job for the Google provider.
--- @param job table The job object.
--- @param code number The exit code.
--- @param callback fun(docs: string|nil, err_msg: string|nil) The callback function.
local function handle_job_exit(job, code, callback)
    if code ~= 0 then
        local error_message = table.concat(job:stderr_result(), "")
        callback(nil, "Error generating Google response: " .. error_message)
        return
    end

    local result = table.concat(job:result(), "")
    local ok, data = pcall(vim.json.decode, result)

    if not ok then
        callback(nil, "Failed to decode Google API response: " .. tostring(data))
        return
    end

    if data.error then
        callback(nil, "Google API error: " .. data.error.message)
        return
    end

    if
        data.candidates
        and data.candidates[1]
        and data.candidates[1].content
        and data.candidates[1].content.parts
        and data.candidates[1].content.parts[1]
    then
        callback(data.candidates[1].content.parts[1].text)
    else
        callback(nil, "Could not extract text from Google API response")
    end
end

--- Generates a response using the Google LLM provider.
--- @param prompt string The prompt to send to Google.
--- @param callback fun(docs: string|nil, err_msg: string|nil) Callback with the response or an error.
--- @param opts table The options for the Google provider. Must contain `model` and `api_key`.
function M.generate_response(prompt, callback, opts)
    if not opts.api_key or opts.api_key == "" then
        callback(nil, "Google API key is not configured. Set the GOOGLE_API_KEY environment variable.")
        return
    end

    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. opts.model .. ":generateContent"

    local body = {
        contents = {
            {
                parts = {
                    {
                        text = prompt,
                    },
                },
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
            "x-goog-api-key: " .. opts.api_key,
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
