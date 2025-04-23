local M = {}

local ns_id = vim.api.nvim_create_namespace("docscribe_highlight")

local spinner_chars = { "|", "/", "-", "\\" }
local current_spinner_idx = 0
local spinner_timer
local spinner_notification_id

--- Starts an animated spinner notification for documenting a function.
---
--- This function initiates a timer-driven spinner animation in the status line,
--- providing real-time feedback that documentation is being generated for a function.
--- The spinner stops once the documentation generation is complete, and a final message is displayed.
---
--- @return nil
function M.start_spinner_notification()
    -- Only start if not already running
    if spinner_timer then
        return
    end

    current_spinner_idx = 0

    -- Create the timer first (but don't start it yet)
    --- @diagnostic disable-next-line: undefined-field
    spinner_timer = vim.loop.new_timer()

    -- Define the update function
    local function update_spinner()
        current_spinner_idx = (current_spinner_idx % #spinner_chars) + 1

        spinner_notification_id =
            M.docscribe_notify(spinner_chars[current_spinner_idx] .. " Generating docs...", vim.log.levels.WARN, {
                timeout = false,
                hide_from_history = true,
                replace = spinner_notification_id,
            })
    end

    -- Start the timer and make the first update immediately
    spinner_timer:start(0, 100, function()
        vim.schedule(update_spinner)
    end)
end

--- Stops the spinner animation and displays the final message.
---
--- This function stops the spinner and replaces the notification with a success or error message,
--- depending on the `caught_error` flag.
---
--- @param message string The message to display (e.g., success or error).
--- @param caught_error boolean|nil If true, the message is displayed as an error; otherwise, as informational.
---
--- @return nil
function M.stop_spinner_notification(message, caught_error)
    if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
    end

    local log_level = caught_error and vim.log.levels.ERROR or vim.log.levels.INFO

    if spinner_notification_id then
        M.docscribe_notify(message, log_level, {
            timeout = 2000,
            hide_from_history = false,
            replace = spinner_notification_id,
        })
        spinner_notification_id = nil
    end
end

--- Displays a notification with a fixed title "docscribe.nvim".
---
--- @param message string The content of the notification.
--- @param log_level integer The severity level of the notification (e.g., `vim.log.levels.INFO`, `vim.log.levels.WARN`, `vim.log.levels.ERROR`).
--- @param opts table|nil Additional options for the notification. If not provided, default options are used.
---
--- @return nil
function M.docscribe_notify(message, log_level, opts)
    opts = opts or {}
    opts.title = "docscribe.nvim"
    return vim.notify(message, log_level, opts)
end

--- Highlights the function signature for a given Tree-sitter node.
---
--- This function highlights the portion of the buffer corresponding to the start of a function.
--- Useful for visually indicating which function is being documented.
---
--- @param function_node TSNode The Tree-sitter node representing the function whose signature to highlight.
---
--- @return nil
function M.highlight_signature(function_node)
    local start_row = function_node:range()
    vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", start_row, 0, -1)
end

--- Highlights all lines corresponding to a given function node in the current buffer.
--- Used to visually indicate which function is currently being processed.
---
--- @param node TSNode The Tree-sitter node representing the function to highlight.
function M.highlight_node(node)
    local start_row, _, end_row, _ = node:range()

    for i = start_row, end_row do
        vim.api.nvim_buf_add_highlight(0, ns_id, "DocscribeProcessing", i, 0, -1)
    end
end

--- Clears all highlights added by the docscribe process in the current buffer.
---
--- This should be called after the documentation generation is completed or canceled.
---
--- @return nil
function M.clear_highlight()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

--- Moves the cursor to the start of the function represented by a Tree-sitter node.
---
--- This is particularly useful for large functions where the user may be far from the function signature.
---
--- @param node TSNode The Tree-sitter node representing the function.
---
--- @return nil
function M.jump_to_node_start(node)
    local start_row, start_col = node:range()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

return M
