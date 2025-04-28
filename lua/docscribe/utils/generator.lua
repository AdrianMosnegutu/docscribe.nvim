local config = require("docscribe.config")
local node_utils = require("docscribe.utils.node")
local doc_utils = require("docscribe.utils.doc")
local llm_utils = require("docscribe.utils.llm")
local notification_utils = require("docscribe.ui.notifications")
local highlight_utils = require("docscribe.ui.highlights")

local M = {}

local is_generating = false
local docs_are_highlighted = false

local function handle_successful_doc_generation(insertion_row, docs)
    notification_utils.stop_spinner_notification("Successfully generated docs")
    highlight_utils.clear_highlight()

    local err = doc_utils.insert_docs(insertion_row, 0, docs)
    if err then
        notification_utils.docscribe_notify(err, vim.log.levels.ERROR)
    end

    local docs_node = node_utils.get_node_at_position(insertion_row, 0)
    if not docs_node then
        return
    end

    highlight_utils.highlight_node(docs_node)
    docs_are_highlighted = true

    --- @diagnostic disable-next-line: undefined-field
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

function M.is_generating()
    return is_generating
end

function M.generate_docs(function_text, insertion_row)
    is_generating = true
    docs_are_highlighted = false

    notification_utils.start_spinner_notification()

    llm_utils.generate_docs(function_text, function(docs, err)
        is_generating = false

        if not docs then
            notification_utils.stop_spinner_notification("Could not generate docs: " .. err, true)
            vim.schedule(highlight_utils.clear_highlight)
            return
        end

        vim.schedule(function()
            handle_successful_doc_generation(insertion_row, docs)
        end)
    end)
end

return M
