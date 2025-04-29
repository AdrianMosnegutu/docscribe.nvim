--- @module "docscribe.utils.node"
---
--- This module provides utilities for interacting with Tree-sitter nodes in
--- the current buffer. It includes functions for retrieving function nodes,
--- extracting node text, deleting node rows, and more. These utilities are
--- designed to facilitate working with AST (Abstract Syntax Tree) nodes in
--- Neovim for tasks like code introspection and manipulation.

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
--- searching upwards in the syntax tree.
---
--- This function traverses the Tree-sitter AST (Abstract Syntax Tree) upwards
--- starting from the current cursor position, looking for the outermost function
--- node. If no function node is found, it returns an error message.
---
--- @return TSNode|nil function_node A Tree-sitter node representing the function,
--- or nil if no function is found.
--- @return string|nil error_msg An error message if no function node is found.
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

--- Retrieves the text content of a given Tree-sitter node.
---
--- This function extracts the text within the range of the provided node
--- from the current buffer and returns it as a single string.
---
--- @param node TSNode The Tree-sitter node to extract text from.
---
--- @return string text The text content of the node.
function M.get_node_text(node)
    local bufnr = vim.api.nvim_get_current_buf()

    -- Fetch the node text bound by its range
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    return table.concat(lines, "\n")
end

--- Retrieves the Tree-sitter node at the specified position (row and column)
--- in the current buffer.
---
--- This function identifies the Tree-sitter node at a given row and column
--- in the current buffer. It validates the row to ensure it is within bounds
--- and checks if a valid Tree-sitter parser is available.
---
--- @param row integer The row number (0-indexed).
--- @param column integer The column number (0-indexed).
---
--- @return TSNode|nil node The Tree-sitter node at the specified position,
--- or nil if no node is found.
--- @return string|nil error_msg An error message if the row is out of bounds
--- or no node is found.
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

--- Deletes the rows of text corresponding to a given Tree-sitter node.
---
--- This function removes all lines of text that fall within the range of
--- the provided Tree-sitter node in the current buffer.
---
--- @param node TSNode The Tree-sitter node whose range will be deleted from
--- the buffer.
function M.delete_node_rows(node)
    local start_row, _, end_row, _ = node:range()
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
end

--- Jumps the cursor to the start position of a given Tree-sitter node.
---
--- This function moves the cursor to the starting row and column of the provided
--- Tree-sitter node in the current window.
---
--- @param node TSNode The Tree-sitter node to jump to.
function M.jump_to_node_start(node)
    local start_row, start_col = node:range()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

--- Gets the number of leading spaces (indentation) before the function
--- definition starts.
---
--- This function checks the line where the `function_node` starts and counts
--- the number of spaces before the first non-space character, up to the
--- function's column position.
---
--- **Use Case:**
--- - Useful for determining the correct indentation level when inserting
---   documentation above the function.
---
--- @param function_node TSNode Tree-sitter node representing a function.
---
--- @return integer indentation_level The number of leading spaces (indentation width)
--- before the function keyword.
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
