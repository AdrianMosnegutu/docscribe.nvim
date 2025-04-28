--- @module "docscribe.utils.doc"
--- A module for handling documentation insertion and retrieval for function nodes.

local node_utils = require("docscribe.utils.node")

local M = {}

--- Retrieves the associated documentation node for the given function node.
---
--- @param function_node TSNode The function node to search for associated documentation above.
---
--- @return TSNode|nil documentation_node The comment node associated with the function, or nil if no comment is found above.
function M.get_associated_docs_node(function_node)
	-- Check if the function declaration is on the first line of the buffer
	local start_row = function_node:range()
	if start_row == 0 then
		return nil
	end

	-- Check if the node directly above the function node is a comment
	local above_node = node_utils.get_node_at_position(start_row - 1, 0)
	if not above_node or above_node:type() ~= "comment" then
		return nil
	end

	return above_node
end

--- Inserts documentation at the specified row with the given indentation level.
---
--- @param row integer The row at which the documentation should be inserted.
--- @param indentation_level integer The number of spaces to use for indentation.
--- @param docs string The documentation string to insert.
---
--- @return string|nil error_msg An error message if the insertion fails, or nil if successful.
function M.insert_docs(row, indentation_level, docs)
	-- Check that the docs exist
	if #docs == 0 then
		return "Could not insert docs: no docs provided"
	end

	-- Check that the indentation level is valid
	if indentation_level < 0 then
		return "Could not insert docs: indentation level is negative"
	end

	-- Check that the row is valid
	local bufnr = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if row < 0 or row >= line_count + 1 then
		return "Could not insert docs: invalid row"
	end

	-- Trim the ends and split the docs into a list of its lines
	docs = docs:gsub("\n+$", "")
	local lines = vim.split(docs, "\n", { plain = true })

	-- Add indentation to each line
	local indentation = string.rep(" ", indentation_level)
	for i, line in ipairs(lines) do
		lines[i] = indentation .. line
	end

	vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
end

return M
