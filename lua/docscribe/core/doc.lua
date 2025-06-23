--- @module "docscribe.core.doc"
--- Utilities for handling documentation insertion and retrieval.

local node_utils = require("docscribe.core.node")

local M = {}

--- Retrieves the documentation node associated with a function node.
--- @param function_node TSNode The function node.
--- @return TSNode|nil docs_node The associated comment node or `nil`.
function M.get_associated_docs_node(function_node)
    local row, col = function_node:range()
    if row == 0 then
        return nil
    end

    -- Adjust the column to be within the bounds of the previous line
    local line_before = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    col = math.min(col, #line_before - 1)

    local above_node = node_utils.get_node_at_position(row - 1, col)
    if not above_node or above_node:type() ~= "comment" then
        return nil
    end

    return above_node
end

--- Inserts documentation at a specified row with proper indentation.
--- @param row integer The 0-based row index for insertion.
--- @param indentation_level integer The number of spaces for indentation.
--- @param docs string The documentation string to insert.
--- @return string|nil err An error message on failure, otherwise `nil`.
function M.insert_docs(row, indentation_level, docs)
    if #docs == 0 then
        return "Could not insert docs: no docs provided"
    end

    if indentation_level < 0 then
        return "Could not insert docs: indentation level is negative"
    end

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
