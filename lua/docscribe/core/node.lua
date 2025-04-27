--- @module "docscribe.core.node"
--- A module that provides utilities for interacting with Treesitter nodes in the current buffer.
--- This includes functions for retrieving function nodes, extracting node text, and deleting node rows.

local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

--- List of function node types that are recognized by the module.
local function_node_types = {
	"function_declaration",
	"function_definition",
	"function_expression",
	"method_definition",
	"method_declaration",
	"arrow_function",
}

--- Retrieves the outermost function node at the current cursor position, searching upwards in the tree.
---
--- @return TSNode|nil function_node A Treesitter node representing the function, or nil if no function is found.
--- @return string|nil error_msg An error message if no function is selected.
function M.get_function_node()
	local current_node = ts_utils.get_node_at_cursor()
	local function_node = nil

	-- Go up the tree while caching the latest function node
	while current_node do
		-- Check if the current node is a function node
		if vim.tbl_contains(function_node_types, current_node:type()) then
			function_node = current_node
		end

		current_node = current_node:parent()
	end

	if not function_node then
		return nil, "No function selected"
	end

	return function_node
end

--- Retrieves the text content of a given node.
---
--- @param node TSNode|nil The Treesitter node to extract text from.
---
--- @return string|nil text The text content of the node.
--- @return string|nil error_msg An error message if the node is nil.
function M.get_node_text(node)
	if not node then
		return nil, "Could not extract node text, node was nil"
	end

	-- Get the node text based on the node's range within the current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = node:range()
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

	return table.concat(lines, "\n")
end

--- Retrieves the node at the specified position (row and column) in the current buffer.
---
--- @param row integer The row number (0-indexed).
--- @param column integer The column number (0-indexed).
---
--- @return TSNode|nil node The Treesitter node at the specified position.
--- @return string|nil error_msg An error message if no node is found
function M.get_node_at_position(row, column)
	local bufnr = vim.api.nvim_get_current_buf()

	-- Make a protected call to the get_parser function in order to catch any exception
	local success, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not success or not parser then
		return nil, "Treesitter could not build parser"
	end

	-- Get the root of the parser's tree and return the descendant located at the given position
	local tree = parser:parse()[1]
	local root = tree:root()
	return root:named_descendant_for_range(row, column, row, column)
end

--- Deletes the rows of text corresponding to a given node.
---
--- @param node TSNode|nil The Treesitter node whose range will be deleted from the buffer.
---
--- @return string|nil error_msg An error message if the node is nil, otherwise nil.
function M.delete_node_rows(node)
	if not node then
		return "Could not delete node, node was nil"
	end

	-- Delete the row range of the given node
	local start_row, _, end_row, _ = node:range()
	vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
end

return M
