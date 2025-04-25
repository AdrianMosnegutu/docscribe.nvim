local node_utils = require("docscribe.core.node")
local doc_utils = require("docscribe.core.doc")
local generator_utils = require("docscribe.core.generator")
local ui = require("docscribe.ui")

local M = {}

--- Generates documentation for the function under the cursor.
---
--- This function performs the following steps:
--- 1. Checks if a documentation generation task is already in progress to prevent overlaps.
--- 2. Finds the nearest function-like Tree-sitter node at the current cursor position.
--- 3. Extracts the source text of the function node.
--- 4. Detects if there's an existing documentation comment directly above the function.
---    - If found, it deletes the old comment and replaces it with newly generated docs.
--- 5. Invokes the documentation generator, which uses the LLM backend and UI tools
---    to generate, insert, and highlight the docs.
---
--- UI feedback is given through notifications and a spinner, and the function is highlighted
--- during generation for visual clarity.
---
--- Supports:
--- - Regeneration of docs if already present
--- - Multiple function types (arrow, method, declaration, etc.)
---
--- @return nil
function M.generate_docs_for_function_under_cursor()
	if generator_utils.is_generating() then
		ui.docscribe_notify("Already generating docs for a function!", vim.log.levels.ERROR)
		return
	end

	local function_node, function_node_err = node_utils.get_function_node()
	if not function_node then
		--- @diagnostic disable-next-line: param-type-mismatch
		ui.docscribe_notify(function_node_err, vim.log.levels.ERROR)
		return
	end

	local function_text, node_text_err = node_utils.get_node_text(function_node)
	if not function_text then
		--- @diagnostic disable-next-line: param-type-mismatch
		ui.docscribe_notify(node_text_err, vim.log.levels.ERROR)
		return
	end

	local docs_node = doc_utils.associated_docs_node(function_node)
	local insertion_row = docs_node and docs_node:range() or function_node:range()

	local lang = vim.bo.filetype
	if lang == "python" then
		insertion_row = insertion_row + 1
	end

	generator_utils.generate_docs(function_node, function_text, insertion_row)
	if docs_node then
		node_utils.delete_node(docs_node)
	end
end

return M
