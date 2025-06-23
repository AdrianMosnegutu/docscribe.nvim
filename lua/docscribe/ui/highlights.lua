--- @module "docscribe.ui.highlights"
--- Utilities for handling highlights.

local M = {}

-- Namespace ID for highlights.
local ns_id = vim.api.nvim_create_namespace("docscribe_highlight")

--- Highlights the signature of a function node.
--- @param function_node TSNode The function node to highlight.
function M.highlight_signature(function_node)
    local start_row = function_node:range()

    --- @diagnostic disable-next-line: deprecated
    vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", start_row, 0, -1)
end

--- Highlights all lines of a node.
--- @param node TSNode The node to highlight.
function M.highlight_node(node)
    local start_row, _, end_row, _ = node:range()

    for i = start_row, end_row do
        --- @diagnostic disable-next-line: deprecated
        vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", i, 0, -1)
    end
end

--- Clears all highlights.
function M.clear_highlight()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M
