--- @module "docscribe.ui.highlights"
---
--- This module provides utility functions for handling highlights in the
--- `docscribe.nvim` plugin.
---
--- It leverages Neovim's highlighting API to visually indicate processing or
--- active regions in the buffer.

local M = {}

-- Namespace ID for highlights created by this module.
local ns_id = vim.api.nvim_create_namespace("docscribe_highlight")

--- Highlights the first line where the given function node is located.
--- This is useful for visually indicating the function being processed.
---
--- @param function_node TSNode: A Treesitter node representing the function
--- to highlight.
function M.highlight_signature(function_node)
    local start_row = function_node:range()

    --- @diagnostic disable-next-line: deprecated
    vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", start_row, 0, -1)
end

--- Highlights all lines covered by the given node.
--- This is useful for visually emphasizing a specific range of lines in
--- the buffer.
---
--- @param node TSNode: A Treesitter node representing the range to highlight.
function M.highlight_node(node)
    local start_row, _, end_row, _ = node:range()

    for i = start_row, end_row do
        --- @diagnostic disable-next-line: deprecated
        vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", i, 0, -1)
    end
end

--- Clears all highlights created by this module.
--- This removes any visual indicators previously added to the buffer.
function M.clear_highlight()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M
