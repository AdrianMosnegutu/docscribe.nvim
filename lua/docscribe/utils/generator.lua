--- @module "docscribe.utils.generator"
---
--- This module handles the process of generating documentation for functions
--- using an LLM (Large Language Model) and managing the associated UI updates.
--- It ensures that the documentation is generated, inserted, and highlighted
--- while providing notifications to the user during the process.

local config = require("docscribe.config")
local node_utils = require("docscribe.utils.node")
local doc_utils = require("docscribe.utils.doc")
local llm_utils = require("docscribe.utils.llm")
local notification_utils = require("docscribe.ui.notifications")
local highlight_utils = require("docscribe.ui.highlights")

local M = {}

--- Tracks whether documentation generation is currently in progress.
local is_generating = false

--- Tracks whether the generated documentation is currently highlighted.
local docs_are_highlighted = false

--- Handles the successful generation of documentation.
---
--- This function is called when the LLM successfully generates documentation.
--- It inserts the generated documentation at the specified row with the given
--- indentation level, highlights the inserted documentation, and sets a timer
--- to clear the highlight after a configurable timeout.
---
--- @param docs string The generated documentation text.
--- @param insertion_row integer The row where the documentation should be inserted.
--- @param indentation_level integer The number of spaces to use for indenting the documentation.
local function handle_successful_doc_generation(docs, insertion_row, indentation_level)
    -- Replace the spinner with the success state notification
    notification_utils.stop_spinner_notification("Successfully generated docs")

    -- Clear the loading state function highlight
    highlight_utils.clear_highlight()
    docs_are_highlighted = false

    -- Try to insert the docs in the specified position
    local insertion_err = doc_utils.insert_docs(insertion_row, indentation_level, docs)
    if insertion_err then
        notification_utils.docscribe_notify(insertion_err, vim.log.levels.ERROR)
        return
    end

    -- Try to get the docs node that was just inserted
    local docs_node, docs_node_err = node_utils.get_node_at_position(insertion_row, indentation_level)
    if not docs_node then
        --- @diagnostic disable-next-line: param-type-mismatch
        notification_utils.docscribe_notify(docs_node_err, vim.log.levels.ERROR)
        return
    end

    -- Highlight the generated docs
    highlight_utils.highlight_node(docs_node)
    docs_are_highlighted = true

    -- After a set amount of time (the highlight timeout config option), clear the
    -- docs highlight
    local timer = vim.loop.new_timer()
    timer:start(config.get_config("ui").highlight.timeout, 0, function()
        vim.schedule(function()
            if docs_are_highlighted then
                highlight_utils.clear_highlight()
            end
            docs_are_highlighted = false
        end)
    end)
end

--- Checks whether documentation generation is currently in progress.
---
--- @return boolean is_generating True if documentation is being generated, false otherwise.
function M.is_generating()
    return is_generating
end

--- Generates documentation for the given function code.
---
--- This function triggers the LLM to generate documentation for the provided
--- function code. It displays a spinner notification while the generation is in
--- progress and handles the insertion of the generated documentation upon success.
---
--- If the generation fails, it shows an error notification and clears any
--- highlights.
---
--- @param function_text string The code for which documentation needs to be generated.
--- @param insertion_row integer The row where the generated documentation should be inserted.
--- @param indentation_level integer The number of spaces to use for indenting the documentation.
function M.generate_docs(function_text, insertion_row, indentation_level)
    is_generating = true
    docs_are_highlighted = false

    -- Start the loading state
    notification_utils.start_spinner_notification()

    -- Create an async job for generating the docs and wait for the response
    llm_utils.generate_docs(function_text, function(docs, err)
        is_generating = false

        -- If doc generation failed, show the error and clear all highlights
        if not docs then
            vim.schedule(function()
                notification_utils.stop_spinner_notification("Could not generate docs: " .. err, true)
                highlight_utils.clear_highlight()
            end)
            return
        end

        -- Handle successfull docstring generation
        vim.schedule(function()
            handle_successful_doc_generation(docs, insertion_row, indentation_level)
        end)
    end)
end

return M
