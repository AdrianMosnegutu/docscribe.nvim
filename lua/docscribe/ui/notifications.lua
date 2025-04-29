local config = require("docscribe.config")

local M = {}

local spinner_chars = { "|", "/", "-", "\\" }
local current_spinner_idx = 0
local spinner_timer
local spinner_notification_id

local is_updating = false

function M.docscribe_notify(message, log_level, opts)
    opts = opts or {}
    opts.title = "docscribe.nvim"
    return vim.notify(message, log_level, opts)
end

function M.start_spinner_notification()
    if spinner_timer then
        return
    end

    current_spinner_idx = 0

    --- @diagnostic disable-next-line: undefined-field
    spinner_timer = vim.loop.new_timer()

    local function update_spinner()
        if is_updating then
            return
        end

        is_updating = true

        current_spinner_idx = (current_spinner_idx % #spinner_chars) + 1

        if not spinner_notification_id then
            spinner_notification_id =
                M.docscribe_notify(spinner_chars[current_spinner_idx] .. " Generating docs...", vim.log.levels.WARN, {
                    timeout = false,
                    hide_from_history = true,
                })
        else
            -- If notification_id exists, replace it
            spinner_notification_id =
                M.docscribe_notify(spinner_chars[current_spinner_idx] .. " Generating docs...", vim.log.levels.WARN, {
                    timeout = false,
                    hide_from_history = true,
                    replace = spinner_notification_id,
                })
        end

        is_updating = false
    end

    spinner_timer:start(0, 100, function()
        vim.schedule(update_spinner)
    end)
end

function M.stop_spinner_notification(message, caught_error)
    if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
    end

    local log_level = caught_error and vim.log.levels.ERROR or vim.log.levels.INFO

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
