--- @module "docscribe.commands.generate_docs"
---
--- This module provides functions to generate and manage inline documentation for
--- functions in code files. It integrates with various utilities for handling nodes,
--- generating documentation, managing UI highlights, and sending notifications.
---
--- The main functionality includes:
--- - Highlighting function nodes based on user configuration.
--- - Generating documentation for the function under the cursor and inserting it
---   at the appropriate location in the code file.

local config = require("docscribe.config")
local node_utils = require("docscribe.core.node")
local doc_utils = require("docscribe.core.doc")
local generator_utils = require("docscribe.core.generator")
local highlight_utils = require("docscribe.ui.highlights")
local notification_utils = require("docscribe.ui.notifications")

local M = {}

--- Highlights a function node based on the user's configuration.
---
--- This function clears all existing highlights and applies a new highlight style
--- to the function node. The style can be either:
--- - "full" (highlights the entire function block).
--- - "signature" (highlights only the function's signature row).
--- - "none" (doesn't highlight the function)
---
--- @param function_node TSNode The Treesitter node representing the function to highlight.
local function highlight_function(function_node)
    local highlight_style = config.get_config("ui").highlight.style

    -- To highlight a function, we first need to clear all other highlights
    highlight_utils.clear_highlight()

    if highlight_style == "full" then -- The entire function block is highlighted
        highlight_utils.highlight_node(function_node)
    elseif highlight_style == "signature" then -- Only the function signature's row is highlighted
        highlight_utils.highlight_signature(function_node)
    end
end

--- Generates documentation for the function under the cursor and inserts it into
--- the code file.
---
--- This function performs the following steps:
--- 1. Checks if documentation generation is already in progress.
--- 2. Identifies the outer-most function node under the cursor.
--- 3. Retrieves the function code and highlights the function node.
--- 4. Determines the insertion row for the generated documentation:
---    - If a docstring already exists, it replaces the old docstring.
---    - Otherwise, it inserts the documentation above the function.
--- 5. Generates and inserts the documentation using the appropriate indentation level.
--- 6. Deletes the old docstring (if present) after inserting the new one.
---
--- Special behavior for Python files:
--- - Docstrings are nested within the function and placed under the function definition.
--- - The insertion row and indentation level are adjusted accordingly.
function M.generate_docs_command()
    -- Check if the plugin is already generating docs for another function
    if generator_utils.is_generating() then
        notification_utils.docscribe_notify("Already generating docs for a function!", vim.log.levels.ERROR)
        return
    end

    -- Get the outer-most function from under the cursor
    local function_node, function_node_err = node_utils.get_function_node()
    if not function_node then
        --- @diagnostic disable-next-line: param-type-mismatch
        notification_utils.docscribe_notify(function_node_err, vim.log.levels.ERROR)
        return
    end

    -- Get the function's code
    local function_text, node_text_err = node_utils.get_node_text(function_node)
    if not function_text then
        --- @diagnostic disable-next-line: param-type-mismatch
        notification_utils.docscribe_notify(node_text_err, vim.log.levels.ERROR)
        return
    end

    -- Jump to the function's start and highlight it based on the user config
    highlight_function(function_node)
    node_utils.jump_to_node_start(function_node)

    -- If the function already had an associated docstring, then the insertion row
    -- is that of the old docstring, otherwise, it is the function's starting row
    local docs_node = doc_utils.get_associated_docs_node(function_node)
    local insertion_row = docs_node and docs_node:range() or function_node:range()
    local indentation_level = node_utils.get_function_indentation(function_node)

    -- Python docs are situated under the function definition and are nested within it
    local lang = vim.bo.filetype
    if lang == "python" then
        insertion_row = insertion_row + 1
        indentation_level = indentation_level + 4
    end

    -- Generate the docs for the given function code and situate them at the
    -- specified row and with the specified indentation level
    generator_utils.generate_docs(function_text, insertion_row, indentation_level)

    -- After the main generating logic, delete the old docs. This must be done at the
    -- end so that row deletion doesn't affect the generation and insertion logic
    if docs_node then
        node_utils.delete_node_rows(docs_node)
    end
end

return M
