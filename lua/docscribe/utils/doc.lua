--- @module "docscribe.utils.doc"
---
--- This module provides utilities for handling documentation insertion and retrieval
--- for function nodes in code files. It includes methods for locating associated
--- documentation nodes and inserting documentation at a specified location in the
--- code with proper formatting and indentation.

local node_utils = require("docscribe.utils.node")

local M = {}

--- Retrieves the associated documentation node for a given function node.
---
--- This function checks if there is a comment node directly above the given
--- function node and returns it as the associated documentation node. If no
--- comment node is found, it returns `nil`.
---
--- **Use Case:**
--- - This is useful for identifying existing docstrings that need to be updated
---   or replaced when generating new documentation for a function.
---
--- @param function_node TSNode The function node for which to search for an
--- associated documentation node.
---
--- @return TSNode|nil documentation_node The comment node directly above the
--- function node, or `nil` if no comment is found.
function M.get_associated_docs_node(function_node)
    -- Check if the function declaration is on the first line of the buffer
    local row, col = function_node:range()
    if row == 0 then
        return nil
    end

    -- Adjust the column to be within the bounds of the previous line
    local line_before = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    col = math.min(col, #line_before - 1)

    -- Check if the node directly above the function node is a comment
    local above_node = node_utils.get_node_at_position(row - 1, col)
    if not above_node or above_node:type() ~= "comment" then
        return nil
    end

    return above_node
end

--- Inserts documentation at a specified row with proper indentation.
---
--- This function inserts a multi-line documentation string (`docs`) at the
--- specified row in the current buffer, applying the given indentation level
--- to each line of the documentation.
---
--- **Use Case:**
--- - This is useful for adding docstrings or comments for a function in a
---   structured and formatted way.
---
--- **Error Handling:**
--- - If the documentation string is empty, an error message is returned.
--- - If the indentation level is negative, an error message is returned.
--- - If the row is invalid (e.g., outside the buffer's line range), an error
---   message is returned.
---
--- @param row integer The row index (0-based) where the documentation should
--- be inserted. Rows start at 0 for the first line.
--- @param indentation_level integer The number of spaces to use for indentation.
--- Must be non-negative.
--- @param docs string The documentation string to insert. It can be multi-line.
---
--- @return string|nil error_msg An error message if the insertion fails, or `nil`
--- if the insertion is successful.
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
