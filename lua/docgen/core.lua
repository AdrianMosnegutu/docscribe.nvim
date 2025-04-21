local ts_utils = require("nvim-treesitter.ts_utils")

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

--- Retrieves the source code text corresponding to a given Treesitter node.
---
--- @param node TSNode The Treesitter node to extract text from.
--- @return string|nil text The text content of the node, or nil if no node is provided.
function M.get_node_text(node)
    if not node then
        return nil
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    return table.concat(lines, "\n")
end

function M.generate()
    local function_node, err = M.get_function_node()
    if not function_node then
        vim.notify("[docgen] " .. err, vim.log.levels.ERROR)
        return
    end

    local function_code = M.get_node_text(function_node)
    if not function_code then
        vim.notify("[docgen] Could not get the function text", vim.log.levels.ERROR)
        return
    end

    vim.notify(function_code)
end

return M
