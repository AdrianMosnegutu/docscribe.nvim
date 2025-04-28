local config = require("docscribe.config")
local node_utils = require("docscribe.utils.node")
local doc_utils = require("docscribe.utils.doc")
local generator_utils = require("docscribe.utils.generator")
local highlight_utils = require("docscribe.ui.highlights")
local notification_utils = require("docscribe.ui.notifications")

local M = {}

local function highlight_function(function_node)
	highlight_utils.clear_highlight()
	local highlight_style = config.get_config("ui").highlight.style

	if highlight_style == "full" then
		highlight_utils.highlight_node(function_node)
	elseif highlight_style == "signature" then
		highlight_utils.highlight_signature(function_node)
	end
end

function M.generate_docs_command()
	if generator_utils.is_generating() then
		notification_utils.docscribe_notify("Already generating docs for a function!", vim.log.levels.ERROR)
		return
	end

	local function_node, function_node_err = node_utils.get_function_node()
	if not function_node then
		notification_utils.docscribe_notify(function_node_err, vim.log.levels.ERROR)
		return
	end

	local function_text, node_text_err = node_utils.get_node_text(function_node)
	if not function_text then
		notification_utils.docscribe_notify(node_text_err, vim.log.levels.ERROR)
		return
	end

	node_utils.jump_to_node_start(function_node)
	highlight_function(function_node)

	local docs_node = doc_utils.get_associated_docs_node(function_node)
	local insertion_row = docs_node and docs_node:range() or function_node:range()

	local lang = vim.bo.filetype
	if lang == "python" then
		insertion_row = insertion_row + 1
	end

	generator_utils.generate_docs(function_text, insertion_row)
	if docs_node then
		node_utils.delete_node_rows(docs_node)
	end
end

return M
