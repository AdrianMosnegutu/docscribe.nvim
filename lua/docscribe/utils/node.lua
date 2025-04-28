--- @module "docscribe.utils.node"
---
--- A module that provides utilities for interacting with Treesitter nodes in
--- the current buffer.
---
--- This includes functions for retrieving function nodes, extracting node text,
--- and deleting node rows.

local ts_utils = require("nvim-treesitter.ts_utils")

--- List of function node types that are recognized by the module.
local function_node_types = {
    "function_declaration",
    "function_definition",
    "function_expression",
    "method_definition",
    "method_declaration",
    "arrow_function",
}

local M = {}

--- Retrieves the outermost function node at the current cursor position,
--- searching upwards in the tree.
---
--- @return TSNode|nil function_node A Treesitter node representing the function,
--- or nil if no function is found.
--- @return string|nil error_msg An error message if no function is selected.
function M.get_function_node()
    local current_node = ts_utils.get_node_at_cursor()
    local function_node = nil

    while current_node do
        if vim.tbl_contains(function_node_types, current_node:type()) then
            function_node = current_node
        end
        current_node = current_node:parent()
    end

    if not function_node then
        return nil, "Cursor is not inside a function block"
    end

    return function_node
end

--- Retrieves the text content of a given node.
---
--- @param node TSNode The Treesitter node to extract text from.
---
--- @return string text The text content of the node.
function M.get_node_text(node)
    local bufnr = vim.api.nvim_get_current_buf()

    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    return table.concat(lines, "\n")
end

--- Retrieves the node at the specified position (row and column) in the current
--- buffer.
---
--- @param row integer The row number (0-indexed).
--- @param column integer The column number (0-indexed).
---
--- @return TSNode|nil node The Treesitter node at the specified position.
--- @return string|nil error_msg An error message if the row is out of bounds or
--- no node is found.
function M.get_node_at_position(row, column)
    local bufnr = vim.api.nvim_get_current_buf()
    local total_lines = vim.api.nvim_buf_line_count(bufnr)

    if row < 0 or row >= total_lines then
        return nil, "Could not get node at position: position is out of bounds"
    end

    local success, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not success or not parser then
        return nil, "Could not get node at position: parser is invalid"
    end

    local tree = parser:parse()[1]
    local root = tree:root()
    return root:named_descendant_for_range(row, column, row, column)
end

--- Deletes the rows of text corresponding to a given node.
---
--- @param node TSNode The Treesitter node whose range will be deleted from
--- the buffer.
function M.delete_node_rows(node)
    local start_row, _, end_row, _ = node:range()
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
end

--- Jumps the cursor to the start position of a given Tree-sitter node.
---
--- @param node TSNode The Tree-sitter node to jump to.
function M.jump_to_node_start(node)
    local start_row, start_col = node:range()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

return M
