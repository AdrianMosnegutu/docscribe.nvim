--- @module "docscribe.core.node"
--- Utilities for interacting with Tree-sitter nodes.

local ts_utils = require("nvim-treesitter.ts_utils")

--- Recognized function node types.
local function_node_types = {
    "function_declaration",
    "function_definition",
    "function_expression",
    "method_definition",
    "method_declaration",
    "arrow_function",
}

local M = {}

--- Retrieves the outermost function node at the current cursor position.
--- @return TSNode|nil function_node The function node, or `nil` if not found.
--- @return string|nil err An error message if no function node is found.
function M.get_function_node()
    local current_node = ts_utils.get_node_at_cursor()
    local function_node = nil

    -- Go up the tree from the node under the cursor and memorize the latest
    -- function node we came across along the way
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

--- Retrieves the text content of a Tree-sitter node.
--- @param node TSNode The node to extract text from.
--- @return string node_text The text content of the node.
function M.get_node_text(node)
    local bufnr = vim.api.nvim_get_current_buf()

    -- Fetch the node text bound by its range
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    return table.concat(lines, "\n")
end

--- Retrieves the Tree-sitter node at a specified position.
--- @param row integer The 0-indexed row.
--- @param column integer The 0-indexed column.
--- @return TSNode|nil node The node at the position, or `nil` if not found.
--- @return string|nil err An error message on failure.
function M.get_node_at_position(row, column)
    local bufnr = vim.api.nvim_get_current_buf()
    local total_lines = vim.api.nvim_buf_line_count(bufnr)

    -- Check that the row is within the buffer's bounds
    if row < 0 or row >= total_lines then
        return nil, "Could not get node at position: position is out of bounds"
    end

    -- Check that the parser is valid
    local success, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not success or not parser then
        return nil, "Could not get node at position: parser is invalid"
    end

    -- Get the parser's root node and return the node situated at the specified
    -- position
    local tree = parser:parse()[1]
    local root = tree:root()
    return root:named_descendant_for_range(row, column, row, column)
end

--- Deletes the rows of a Tree-sitter node.
--- @param node TSNode The node to delete.
function M.delete_node_rows(node)
    local start_row, _, end_row, _ = node:range()
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
end

--- Jumps the cursor to the start of a Tree-sitter node.
--- @param node TSNode The node to jump to.
function M.jump_to_node_start(node)
    local start_row, start_col = node:range()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

--- Gets the indentation level of a function node.
--- @param function_node TSNode The function node.
--- @return integer indentation The indentation level.
function M.get_function_indentation(function_node)
    local row, col = function_node:range()

    -- Get the characters from the beginning of the first line of the node up to
    -- the beginning of the node itself
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    local partial_line = line:sub(1, col)

    -- Get the string containing all spaces from the beginning of the line up to
    -- the first non-space character in the line, then return its length
    local spaces = partial_line:match("^(%s*)")
    return #spaces
end

return M
