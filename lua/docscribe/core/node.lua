local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

-- Tree-sitter node types considered function-like
local function_node_types = {
	"function_declaration",
	"function_definition",
	"function_expression",
	"method_definition",
	"method_declaration",
	"arrow_function",
}

--- Gets the nearest function-like Tree-sitter node at the current cursor position.
---
--- Supported node types include:
--- - "function_declaration"
--- - "function_definition"
--- - "function_expression"
--- - "method_definition"
--- - "method_declaration"
--- - "arrow_function"
---
--- @return TSNode|nil node The nearest function node, or nil if not found.
--- @return string|nil err An error message if no function node is found.
function M.get_function_node()
	local current_node = ts_utils.get_node_at_cursor()

	while current_node do
		if vim.tbl_contains(function_node_types, current_node:type()) then
			return current_node
		end
		current_node = current_node:parent()
	end

	return nil, "No function selected"
end

--- Retrieves the source code text corresponding to a given Tree-sitter node.
---
--- @param node TSNode The Tree-sitter node to extract text from.
--- @return string|nil text The text content of the node, or nil if no node is provided.
--- @return string|nil err An error message if extraction fails.
function M.get_node_text(node)
	if not node then
		return nil, "Could not extract node text, node was nil"
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = node:range()
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

	return table.concat(lines, "\n")
end

--- Retrieves the Tree-sitter node located at the given buffer row and column.
---
--- @param row integer The buffer row (0-indexed).
--- @param column integer The column in the row.
--- @return TSNode|nil node The node at the specified position, or nil on failure.
--- @return string|nil err An error message if the parser is unavailable.
function M.get_node_at_position(row, column)
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(bufnr)

	if not parser then
		return nil, "Could not get the treesitter parser"
	end

	local tree = parser:parse()[1]
	local root = tree:root()
	return root:named_descendant_for_range(row, column, row, column)
end

--- Deletes the source text for a given Tree-sitter node from the buffer.
---
--- This removes the text corresponding to the full range of the node.
---
--- @param node TSNode The Tree-sitter node to delete.
function M.delete_node(node)
	local start_row, _, end_row, _ = node:range()
	vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
end

return M
