-- tests/mocks/fake_ts_utils.lua
local M = {}

function M.get_node_at_cursor()
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    row = row - 1 -- API returns 1-based rows, Tree-sitter wants 0-based

    local parser = vim.treesitter.get_parser(bufnr)
    if not parser then
        return nil, "Treesitter parser not available"
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil, "No parse tree available"
    end

    local root = tree:root()
    if not root then
        return nil, "No root node found"
    end

    local node = root:named_descendant_for_range(row, col, row, col)

    return node
end

function M.get_node_text(_)
    return { "mocked_function_name" }
end

return M
