local ts_utils = require("nvim-treesitter.ts_utils")
local llm = require("docgen.llm")
local ui = require("docgen.ui")

local M = {}

local function_node_types = {
    "function_declaration",
    "function_definition",
    "function_expression",
    "method_definition",
    "arrow_function",
}

local is_generating = false

--- Gets the nearest function-like Treesitter node at the current cursor position.
---
--- Supported node types include:
--- "function_declaration", "function_definition", "function_expression",
--- "method_definition" and "arrow_function".
---
--- @return TSNode|nil node The nearest function node, or nil if not found.
--- @return string|nil err An error message if no function node is found.
local function get_function_node()
    -- Get the current treesitter node under the cursor
    local current_node = ts_utils.get_node_at_cursor()

    while current_node do
        -- If the current node is a function declaration, return it
        if vim.tbl_contains(function_node_types, current_node:type()) then
            return current_node
        end

        -- Otherwise, keep iterating up the tree
        current_node = current_node:parent()
    end

    return nil, "No function selected"
end

--- Retrieves the source code text corresponding to a given Treesitter node.
---
--- @param node TSNode The Treesitter node to extract text from.
--- @return string|nil text The text content of the node, or nil if no node is provided.
--- @return string|nil text An error message if no node was provided.
local function get_node_text(node)
    if not node then
        return nil, "Could not extract node text, node was nil"
    end

    -- Extract the text bound by the given node int the current buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    -- The returned lines come as a table, so concatenate them using an endline character
    return table.concat(lines, "\n")
end

--- Inserts a multiline string directly above the given Tree-sitter node in the buffer.
---
--- @param node TSNode: The Tree-sitter node to insert above.
--- @param text string: The text to insert. Can include newline characters.
local function insert_lines_above_node(node, text)
    if not node or not text or text == "" then
        return
    end

    -- Remove trailing newlines
    text = text:gsub("\n+$", "")

    local bufnr = vim.api.nvim_get_current_buf()
    local start_row = node:range() -- 0-indexed line where the node starts

    -- Split the text into lines
    local lines = vim.split(text, "\n", { plain = true })

    vim.api.nvim_buf_set_lines(bufnr, start_row, start_row, false, lines)
end

--- Generates documentation for the function currently under the cursor.
---
--- - If a doc generation is already in progress, the operation is aborted.
--- - The function uses Tree-sitter to find the function node at the cursor.
--- - It extracts the function’s source code, highlights the node, shows a spinner,
---   and moves the cursor to the function's start.
--- - The documentation is then generated asynchronously via the configured LLM,
---   and inserted directly above the function once ready.
---
--- Not thread-safe: concurrent calls are not supported yet and will be ignored.
---
--- @return nil
function M.generate_docs_for_function_under_cursor()
    if is_generating then
        ui.docgen_notify("Already generating docs for a function!", vim.log.levels.ERROR)
        return
    end

    -- Retrieve the function node in which the cursor resided
    local function_node, function_node_err = get_function_node()
    if not function_node then
        --- @diagnostic disable-next-line: param-type-mismatch
        ui.docgen_notify(function_node_err, vim.log.levels.ERROR)
        return
    end

    -- Retrieve thr function node's code
    local function_code, node_text_err = get_node_text(function_node)
    if not function_code then
        --- @diagnostic disable-next-line: param-type-mismatch
        ui.docgen_notify(node_text_err, vim.log.levels.ERROR)
        return
    end

    ui.start_spinner_notification()
    ui.highlight_signature(function_node)
    ui.jump_to_node_start(function_node)

    is_generating = true

    -- Generate asynchronously the docs using the preferred llm
    llm.generate_docs(function_code, function(docs)
        if not docs then
            ui.stop_spinner_notification("Could not generate docs", true)
            return
        end

        ui.stop_spinner_notification("Successfully generated docs")

        vim.schedule(function()
            insert_lines_above_node(function_node, docs)
            ui.clear_highlight()
            is_generating = false
        end)
    end)
end

return M
