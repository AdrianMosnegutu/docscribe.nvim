--- @module "docscribe.ui.notifications"
---
--- This module provides functionality for managing notifications in the
--- `docscribe.nvim` plugin.
---
--- It handles asynchronous user notifications, including starting and stopping
--- a spinner for long-running tasks.

local config = require("docscribe.config")

local M = {}

local spinner_chars = { "|", "/", "-", "\\" } -- Spinner characters used for the spinner animation.
local current_spinner_idx = 0 -- Index of the current spinner character.
local spinner_timer -- Timer handle for controlling the spinner animation.
local spinner_notification_id -- Notification ID for the spinner, used to replace the message dynamically.

--- Updates the spinner animation by cycling through the `spinner_chars`.
--- This function updates the spinner message in the notification.
local function update_spinner()
    -- Make the index cycle infinitely through the spinner chars
    current_spinner_idx = (current_spinner_idx % #spinner_chars) + 1

    -- Create or replace a new frame of the spinner notification
    spinner_notification_id =
        M.docscribe_notify(spinner_chars[current_spinner_idx] .. " Generating docs...", vim.log.levels.WARN, {
            timeout = false,
            hide_from_history = true,
            replace = spinner_notification_id,
        })
end

--- Displays a notification using Neovim's `vim.notify`.
--- The notification always has the title **docscribe.nvim**.
---
--- @param message string The message to display in the notification.
--- @param log_level integer The log level for the notification
--- (e.g., `vim.log.levels.INFO`).
--- @param opts table|nil Optional table of options for configuring the notification.
---
--- @return integer|nil notification_id The notification ID, which can be used to
--- replace or update the notification.
function M.docscribe_notify(message, log_level, opts)
    opts = opts or {}
    opts.title = "docscribe.nvim"
    return vim.notify(message, log_level, opts)
end

--- Starts the spinner notification animation.
--- This function initializes a timer that updates the spinner animation at regular
--- intervals (every 100ms).
function M.start_spinner_notification()
    if spinner_timer then
        return
    end

    current_spinner_idx = 0

    spinner_timer = vim.loop.new_timer()
    spinner_timer:start(0, 100, vim.schedule_wrap(update_spinner))
end

--- Stops the spinner notification and replaces it with a final message.
---
--- @param message string: The final message to display after stopping the spinner.
--- @param caught_an_error boolean: Indicates whether an error occurred, which
--- determines the log level (INFO or ERROR).
function M.stop_spinner_notification(message, caught_an_error)
    if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
    end

    -- Determine the log level
    local log_level = caught_an_error and vim.log.levels.ERROR or vim.log.levels.INFO

    -- Replace the spinner with a final status notification (success or error)
    if spinner_notification_id then
        M.docscribe_notify(message, log_level, {
            timeout = config.get_config("ui").highlight.timeout,
            hide_from_history = false,
            replace = spinner_notification_id,
        })
        spinner_notification_id = nil
    end
end

return M
