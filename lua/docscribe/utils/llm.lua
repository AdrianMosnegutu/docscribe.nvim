local Job = require("plenary.job")
local config = require("docscribe.config")
local notification_utils = require("docscribe.ui.notifications")

local M = {}

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
				notification_utils.docscribe_notify("Error generating Ollama response", vim.log.levels.ERROR)
				callback(nil)
			end
		end,
	}):start()
end

function M.generate_docs(function_code, callback)
	local lang = vim.bo.filetype

	local prompt_templates = config.get_config("prompt_templates")
	local prompt_template = prompt_templates[lang] or prompt_templates.default

	local prompt = prompt_template:gsub("{{code}}", function_code)

	local llm = config.get_config("llm")
	if llm.provider == "ollama" then
		generate_using_ollama(prompt, llm.model, callback)
	else
		notification_utils.docscribe_notify("Invalid LLM runner: " .. llm.provider, vim.log.levels.ERROR)
	end
end

return M
