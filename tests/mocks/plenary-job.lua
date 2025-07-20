local Job = {}

function Job:new(opts)
    self.opts = opts
    return setmetatable({}, { __index = self })
end

function Job:start()
    if not self.opts or not self.opts.on_exit then
        error("Missing required options or on_exit callback in mock Job")
    end

    -- Simulate success or failure based on input
    if self.opts.command == "ollama" and self.opts.args[1] == "run" then
        if self.opts.writer:find("mock_error") then
            -- Simulate a failure case
            self.result = function()
                return {}
            end
            self.opts.on_exit(self, 1) -- Non-zero exit code for error
        else
            -- Simulate a success case
            self.result = function()
                return { "Mocked documentation response" }
            end
            self.opts.on_exit(self, 0) -- Zero exit code for success
        end
    elseif self.opts.command == "curl" then
        -- Handle Google and Groq API calls
        local is_groq = false
        local is_google = false
        
        for _, arg in ipairs(self.opts.args) do
            if arg:find("api.groq.com") then
                is_groq = true
                break
            elseif arg:find("generativelanguage.googleapis.com") then
                is_google = true
                break
            end
        end
        
        if is_groq then
            -- Mock Groq API response
            local groq_response = {
                id = "chatcmpl-mock",
                object = "chat.completion",
                created = 1234567890,
                model = "llama-3.1-8b-instant",
                choices = {
                    {
                        index = 0,
                        message = {
                            role = "assistant",
                            content = "Mocked documentation response"
                        },
                        finish_reason = "stop"
                    }
                }
            }
            self.result = function()
                return { vim.json.encode(groq_response) }
            end
            self.opts.on_exit(self, 0)
        elseif is_google then
            -- Mock Google API response
            local google_response = {
                candidates = {
                    {
                        content = {
                            parts = {
                                {
                                    text = "Mocked documentation response"
                                }
                            }
                        }
                    }
                }
            }
            self.result = function()
                return { vim.json.encode(google_response) }
            end
            self.opts.on_exit(self, 0)
        else
            -- Unknown curl request
            self.result = function()
                return {}
            end
            self.opts.on_exit(self, 1)
        end
    else
        self.result = function()
            return {}
        end
        self.opts.on_exit(self, 1) -- Non-zero exit code for invalid command
    end
end

function Job:result()
    return self.result and self.result() or {}
end

return Job
