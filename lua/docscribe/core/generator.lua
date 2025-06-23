--- @module "docscribe.core.generator"
--- Handles documentation generation using an LLM and manages UI updates.

local config = require("docscribe.config")
local node_utils = require("docscribe.core.node")
local doc_utils = require("docscribe.core.doc")
local llm_utils = require("docscribe.llm")
local notification_utils = require("docscribe.ui.notifications")
local highlight_utils = require("docscribe.ui.highlights")

local M = {}

--- @type boolean Tracks whether documentation generation is in progress.
local is_generating = false

--- @type number Semaphore to ensure only the last call clears highlights.
local current_highlight_token = 0

--- Handles successful documentation generation.
--- Inserts and highlights the generated documentation, then clears the highlight after a timeout.
--- @param docs string The generated documentation.
--- @param insertion_row integer The insertion row.
--- @param indentation_level integer The indentation level.
local function handle_successful_doc_generation(docs, insertion_row, indentation_level)
    notification_utils.replace_spinner_notification("Successfully generated docs")

    highlight_utils.clear_highlight()

    local insertion_err = doc_utils.insert_docs(insertion_row, indentation_level, docs)
    if insertion_err then
        notification_utils.docscribe_notify(insertion_err, vim.log.levels.ERROR)
        return
    end

    local docs_node, docs_node_err = node_utils.get_node_at_position(insertion_row, indentation_level)
    if not docs_node then
        --- @diagnostic disable-next-line: param-type-mismatch
        notification_utils.docscribe_notify(docs_node_err, vim.log.levels.ERROR)
        return
    end

    highlight_utils.highlight_node(docs_node)
    local token = current_highlight_token

    local timer = vim.loop.new_timer()
    local highlight_timeout = config.get_config("ui").highlight.timeout

    timer:start(
        highlight_timeout,
        0,
        vim.schedule_wrap(function()
            -- Make sure only the most recent call clears all highlights
            if token == current_highlight_token then
                highlight_utils.clear_highlight()
            end
        end)
    )
end

--- Checks if documentation generation is in progress.
--- @return boolean True if generating, false otherwise.
function M.is_generating()
    return is_generating
end

--- Generates documentation for the given function code.
--- @param function_text string The function code.
--- @param insertion_row integer The row for documentation insertion.
--- @param indentation_level integer The indentation level.
function M.generate_docs(function_text, insertion_row, indentation_level)
    is_generating = true
    current_highlight_token = current_highlight_token + 1

    notification_utils.start_spinner_notification()
    llm_utils.generate_docs(function_text, function(docs, err)
        is_generating = false

        if not docs then
            vim.schedule(function()
                notification_utils.replace_spinner_notification("Could not generate docs: " .. err, true)
                highlight_utils.clear_highlight()
            end)
            return
        end

        vim.schedule(function()
            handle_successful_doc_generation(docs, insertion_row, indentation_level)
        end)
    end)
end

return M
