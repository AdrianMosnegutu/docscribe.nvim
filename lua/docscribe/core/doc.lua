local node_utils = require("docscribe.core.node")
local ui = require("docscribe.ui")

local M = {}

--- Attempts to find a documentation comment directly above a function node.
---
--- This function checks the line immediately above the start of the given function node.
--- If a comment node is present, it is assumed to be the associated documentation.
---
--- This is a lightweight, fast way to identify pre-existing documentation for potential replacement.
---
--- @param function_node TSNode The Tree-sitter function node to inspect.
--- @return TSNode|nil comment_node The comment node if found, or nil.
function M.associated_docs_node(function_node)
	local start_row = function_node:range()
	if start_row == 0 then
		return nil
	end

	local above_node = node_utils.get_node_at_position(start_row - 1, 0)
	if not above_node or above_node:type() ~= "comment" then
		return nil
	end

	return above_node
end

--- Inserts a block of documentation text at a specific row in the current buffer.
---
--- Used to place generated doc comments just above the function node. Performs basic
--- validation to ensure empty or nil strings are not inserted.
---
--- @param row integer The buffer row at which to insert the docs.
--- @param docs string The documentation string to insert.
function M.insert_docs_at_row(row, docs)
	if not docs or docs == "" then
		ui.docscribe_notify("Could not insert docs: invalid function", vim.log.levels.ERROR)
		return
	end

	docs = docs:gsub("\n+$", "")
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.split(docs, "\n", { plain = true })

	vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
end

return M
