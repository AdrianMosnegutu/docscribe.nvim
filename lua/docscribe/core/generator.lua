local ui = require("docscribe.ui")
local config = require("docscribe.config")
local llm = require("docscribe.llm")
local doc_utils = require("docscribe.core.doc")
local node_utils = require("docscribe.core.node")

local M = {}

-- Internal flag to prevent concurrent doc generation
local is_generating = false

local docs_are_highlighted = false

local function handle_successful_doc_generation(insertion_row, docs)
	doc_utils.insert_docs_at_row(insertion_row, docs)

	ui.stop_spinner_notification("Successfully generated docs")
	ui.clear_highlight()

	local docs_node = node_utils.get_node_at_position(insertion_row, 0)
	if not docs_node then
		return
	end

	ui.highlight_node(docs_node)
	docs_are_highlighted = true

    --- @diagnostic disable-next-line: undefined-field
	local timer = vim.loop.new_timer()
	timer:start(2000, 0, function()
		vim.schedule(function()
			if docs_are_highlighted then
				ui.clear_highlight()
			end
			docs_are_highlighted = false
		end)
	end)
end

--- Checks if a documentation generation process is currently running.
---
--- Prevents concurrent invocations of documentation generation to avoid conflicts
--- like overlapping UI feedback or text insertions.
---
--- @return boolean is_generating Whether a generation process is currently active.
function M.is_generating()
	return is_generating
end

--- Triggers documentation generation for a given function node.
---
--- This function coordinates the full documentation generation pipeline:
--- 1. Flags the system as generating to prevent overlap.
--- 2. Highlights the target function (either the full function or just the signature).
--- 3. Shows a spinner to indicate generation is in progress.
--- 4. Invokes the configured LLM backend to generate doc comments from the function text.
--- 5. Inserts the generated documentation above the function at the specified row.
--- 6. Cleans up the UI (removes highlights/spinners) when finished.
---
--- Handles failure cases gracefully: if no documentation is returned, UI is reset and
--- no changes are made to the buffer.
---
--- @param function_node TSNode The Tree-sitter node representing the function.
--- @param function_text string The raw source text of the function.
--- @param insertion_row integer The row above which the documentation should be inserted.
function M.generate_docs(function_node, function_text, insertion_row)
	is_generating = true
    docs_are_highlighted = false

	local highlight_mode = config.get_config("ui").highlight
	if highlight_mode == "full" then
		ui.highlight_node(function_node)
	elseif highlight_mode == "signature" then
		ui.highlight_signature(function_node)
	end

	ui.start_spinner_notification()
	ui.jump_to_node_start(function_node)

	llm.generate_docs(function_text, function(docs)
		is_generating = false

		if not docs then
			ui.stop_spinner_notification("Could not generate docs", true)
			vim.schedule(ui.clear_highlight)
			return
		end

		vim.schedule(function()
			handle_successful_doc_generation(insertion_row, docs)
		end)
	end)
end

return M
