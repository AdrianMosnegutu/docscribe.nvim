local Job = require("plenary.job")
local config = require("docscribe.config")
local ui = require("docscribe.ui")

local M = {}

--- Generates documentation for the given function code using the configured LLM runner.
---
--- Currently only supports the "ollama" runner. The function builds a prompt
--- using the configured template, injects the function code, and passes the
--- resulting prompt to the appropriate generator.
---
--- @param function_code string The code of the function to generate documentation for.
--- @param callback fun(docs: string | nil) A callback that receives the generated docs as a string,
--- or nil if generation failed.
function M.generate_docs(function_code, callback)
	local prompt_template = config.get_config("prompt_template")
	local prompt = prompt_template:gsub("{{code}}", function_code)

	local runner = config.get_config("runner")
	local model = config.get_config("model")

	if runner == "ollama" then
		M.generate_using_ollama(prompt, model, callback)
	else
		ui.docscribe_notify("Invalid LLM runner: " .. runner, vim.log.levels.ERROR)
	end
end

--- Sends a prompt to the Ollama LLM and invokes a callback with the response.
---
--- Uses `plenary.job` to run `ollama` as an external process with the given model.
--- If the process exits successfully, the response is returned via callback.
---
--- @param prompt string The prompt to send to the model.
--- @param model string The name of the model to use (e.g., "codellama", "gemma").
--- @param callback fun(docs: string | nil) A callback that receives the generated documentation,
--- or nil if the generation failed or the process errored.
function M.generate_using_ollama(prompt, model, callback)
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
				ui.docscribe_notify("Error generating Ollama response", vim.log.levels.ERROR)
				callback(nil)
			end
		end,
	}):start()
end

return M
