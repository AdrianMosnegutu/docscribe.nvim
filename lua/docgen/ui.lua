local M = {}

local spinner_chars = { "|", "/", "-", "\\" }
local current_spinner_idx = 0
local spinner_timer
local spinner_notification_id

--- Starts an animated spinner notification indicating that documentation is being
--- generated for a given function.
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

		spinner_notification_id = M.docgen_notify(
			spinner_chars[current_spinner_idx] .. " Generating docs...",
			vim.log.levels.WARN,
			{
				timeout = false,
				hide_from_history = true,
				replace = spinner_notification_id,
			}
		)
	end

	-- Start the timer and make the first update immediately
	spinner_timer:start(0, 100, function()
		vim.schedule(update_spinner)
	end)
end

--- Stops the spinner animation and replaces the notification with a final message.
---
--- @param message string: The message to display in the final notification
--- (e.g., success or error message).
--- @param caught_error boolean|nil: A flag indicating whether the notification should be an
--- error (`true`) or informational (`false`).
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
		M.docgen_notify(message, log_level, {
			timeout = 3000,
			hide_from_history = false,
			replace = spinner_notification_id,
		})
		spinner_notification_id = nil
	end
end

--- Displays a notification with a fixed title of "docgen.lua". The notification can
--- include custom message content, log level, and options.
---
--- @param message string: The message to display in the notification.
--- @param log_level integer: The log level for the notification, which determines the
--- severity (e.g., `vim.log.levels.INFO`, `vim.log.levels.WARN`, `vim.log.levels.ERROR`).
--- @param opts table|nil: A table of additional options for the notification. If not
--- provided, default options are used. The `title` field is always set to `"docgen.lua"`.
---
--- @return nil
function M.docgen_notify(message, log_level, opts)
	opts = opts or {}
	opts.title = "docgen.nvim"
	return vim.notify(message, log_level, opts)
end

return M
