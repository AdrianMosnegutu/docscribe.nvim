local ts_utils = require("nvim-treesitter.ts_utils")
local llm = require("docgen.llm")

local M = {}

local function_node_types = {
	"function_declaration",
	"function_definition",
	"function_expression",
	"method_definition",
	"arrow_function",
}

--- Gets the nearest function-like Treesitter node at the current cursor position.
---
--- Supported node types include:
--- "function_declaration", "function_definition", "function_expression",
--- "method_definition" and "arrow_function".
---
--- @return TSNode|nil node The nearest function node, or nil if not found.
--- @return string|nil err An error message if no function node is found.
local function get_function_node()
	-- Get the current treesitter node under the cursor
	local current_node = ts_utils.get_node_at_cursor()

	while current_node do
		-- If the current node is a function declaration, return it
		if vim.tbl_contains(function_node_types, current_node:type()) then
			return current_node
		end

		-- Otherwise, keep iterating up the tree
		current_node = current_node:parent()
	end

	return nil, "No function selected"
end

--- Retrieves the source code text corresponding to a given Treesitter node.
---
--- @param node TSNode The Treesitter node to extract text from.
--- @return string|nil text The text content of the node, or nil if no node is provided.
--- @return string|nil text An error message if no node was provided.
local function get_node_text(node)
	if not node then
		return nil, "Could not extract node text, node was nil"
	end

	-- Extract the text bound by the given node int the current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = node:range()
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

	-- The returned lines come as a table, so concatenate them using an endline character
	return table.concat(lines, "\n")
end

function M.generate()
	-- Retrieve the function node in which the cursor resided
	local function_node, function_node_err = get_function_node()
	if not function_node then
		vim.notify("[docgen] " .. function_node_err, vim.log.levels.ERROR)
		return
	end

	-- Retrieve thr function node's code
	local function_code, node_text_err = get_node_text(function_node)
	if not function_code then
		vim.notify("[docgen] " .. node_text_err, vim.log.levels.ERROR)
		return
	end

	-- Generate asynchronously the docs using the preferred llm
	llm.generate_docs(function_code, function(docs)
		if not docs then
			vim.notify("Could not generate docs", vim.log.levels.ERROR)
			return
		end

		vim.notify(docs)
	end)
end

return M
