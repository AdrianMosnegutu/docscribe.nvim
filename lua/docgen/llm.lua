local config = require("docgen.config")
local Job = require("plenary.job")
local ui = require("docgen.ui")

local M = {}

--- Generates documentation for the provided function code using the configured LLM runner.
---
--- @param function_code string: The code of the function to generate documentation for.
--- @param callback fun(docs: string | nil): nil callback function that receives the generated docs,
--- or nil if generation failed.
function M.generate_docs(function_code, callback)
	-- Build the prompt using the template and provided code
	local prompt_template = config.get_config("prompt_template")
	local prompt = prompt_template:gsub("{{code}}", function_code)

	-- Get the llm details
	local runner = config.get_config("runner")
	local model = config.get_config("model")

	-- Execute a query based on the preferred llm
	if runner == "ollama" then
		M.generate_using_ollama(prompt, model, callback)
	else
		ui.docgen_notify("Invalid LLM runner: " .. runner, vim.log.levels.ERROR)
	end
end

--- Sends a prompt to the Ollama model and invokes a callback with the generated documentation.
---
--- @param prompt string: The prompt to send to the model.
--- @param model string: The model name to use with Ollama (e.g., "codellama", "gemma").
--- @param callback fun(docs: string | nil): nil callback function that receives the result,
--- or nil if the generation failed.
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
				vim.notify("Error generating Ollama response", vim.log.levels.ERROR, { title = "docgen.lua" })
				callback(nil)
			end
		end,
	}):start()
end

return M
