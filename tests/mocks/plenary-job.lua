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
