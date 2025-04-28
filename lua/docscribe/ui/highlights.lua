local M = {}

local ns_id = vim.api.nvim_create_namespace("docscribe_highlight")

function M.highlight_signature(function_node)
    local start_row = function_node:range()

    --- @diagnostic disable-next-line: deprecated
    vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", start_row, 0, -1)
end

function M.highlight_node(node)
    local start_row, _, end_row, _ = node:range()

    for i = start_row, end_row do
        --- @diagnostic disable-next-line: deprecated
        vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", i, 0, -1)
    end
end

function M.clear_highlight()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M
