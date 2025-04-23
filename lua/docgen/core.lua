local ts_utils = require("nvim-treesitter.ts_utils")
local llm = require("docgen.llm")
local ui = require("docgen.ui")

local M = {}

-- Tree-sitter node types considered function-like
local function_node_types = {
    "function_declaration",
    "function_definition",
    "function_expression",
    "method_definition",
    "arrow_function",
}

-- Internal flag to prevent concurrent doc generation
local is_generating = false

--- Gets the nearest function-like Tree-sitter node at the current cursor position.
---
--- Supported node types include:
--- - "function_declaration"
--- - "function_definition"
--- - "function_expression"
--- - "method_definition"
--- - "arrow_function"
---
--- @return TSNode|nil node The nearest function node, or nil if not found.
--- @return string|nil err An error message if no function node is found.
local function get_function_node()
    local current_node = ts_utils.get_node_at_cursor()

    while current_node do
        if vim.tbl_contains(function_node_types, current_node:type()) then
            return current_node
        end
        current_node = current_node:parent()
    end

    return nil, "No function selected"
end

--- Retrieves the source code text corresponding to a given Tree-sitter node.
---
--- @param node TSNode The Tree-sitter node to extract text from.
--- @return string|nil text The text content of the node, or nil if no node is provided.
--- @return string|nil err An error message if extraction fails.
local function get_node_text(node)
    if not node then
        return nil, "Could not extract node text, node was nil"
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    return table.concat(lines, "\n")
end

--- Inserts a multiline string directly above the given Tree-sitter node in the buffer.
---
--- Strips trailing newlines from the text and splits it into lines for insertion.
---
--- @param node TSNode The Tree-sitter node to insert above.
--- @param text string The documentation text to insert.
local function insert_lines_above_node(node, text)
    if not node or not text or text == "" then
        return
    end

    text = text:gsub("\n+$", "")
    local bufnr = vim.api.nvim_get_current_buf()
    local start_row = node:range()
    local lines = vim.split(text, "\n", { plain = true })

    vim.api.nvim_buf_set_lines(bufnr, start_row, start_row, false, lines)
end

--- Generates documentation for the function currently under the cursor.
---
--- If a generation is already in progress, notifies the user and aborts.
--- Otherwise, it locates the function, extracts the code, shows UI feedback,
--- invokes the configured LLM to generate documentation, and inserts it above the function.
---
--- @return nil
function M.generate_docs_for_function_under_cursor()
    if is_generating then
        ui.docgen_notify("Already generating docs for a function!", vim.log.levels.ERROR)
        return
    end

    local function_node, function_node_err = get_function_node()
    if not function_node then
        --- @diagnostic disable-next-line: param-type-mismatch
        ui.docgen_notify(function_node_err, vim.log.levels.ERROR)
        return
    end

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

    llm.generate_docs(function_code, function(docs)
        if not docs then
            ui.stop_spinner_notification("Could not generate docs", true)
            return
        end

        vim.schedule(function()
            insert_lines_above_node(function_node, docs)
            is_generating = false

            ui.stop_spinner_notification("Successfully generated docs")
            ui.clear_highlight()
        end)
    end)
end

return M
