require("plenary.busted")

local config = require("docscribe.config")
local node_utils = require("docscribe.utils.node")
local doc_utils = require("docscribe.utils.doc")
local llm_utils = require("docscribe.utils.llm")
local notification_utils = require("docscribe.ui.notifications")
local highlight_utils = require("docscribe.ui.highlights")
local stub = require("luassert.stub")

local M = require("docscribe.utils.generator")

local function stub_dependencies()
    stub(notification_utils, "start_spinner_notification")
    stub(notification_utils, "replace_spinner_notification")
    stub(notification_utils, "docscribe_notify")
    stub(highlight_utils, "clear_highlight")
    stub(highlight_utils, "highlight_node")
    stub(doc_utils, "insert_docs")
    stub(node_utils, "get_node_at_position")
    stub(config, "get_config", function(_)
        return { highlight = { timeout = 100 } }
    end)
    stub(llm_utils, "generate_docs")
end

local function revert_stubs()
    notification_utils.start_spinner_notification:revert()
    notification_utils.replace_spinner_notification:revert()
    notification_utils.docscribe_notify:revert()
    highlight_utils.clear_highlight:revert()
    highlight_utils.highlight_node:revert()
    doc_utils.insert_docs:revert()
    node_utils.get_node_at_position:revert()
    config.get_config:revert()
    llm_utils.generate_docs:revert()
end

local function simulate_llm_response(docs, err)
    llm_utils.generate_docs.invokes(function(_, cb)
        vim.schedule(function()
            cb(docs, err)
        end)
    end)
end

local function wait_for_stub_call(stub_func, timeout)
    vim.wait(timeout or 1000, function()
        return #stub_func.calls > 0
    end, 10)
end

describe("docscribe.utils.generator", function()
    before_each(function()
        stub_dependencies()
    end)

    after_each(function()
        revert_stubs()
    end)

    describe("is_generating", function()
        it("returns false initially", function()
            assert.is_false(M.is_generating())
        end)
    end)

    describe("generate_docs", function()
        it("starts spinner notification and calls LLM generator", function()
            local docs = "Generated documentation"
            simulate_llm_response(docs, nil)

            assert.is_false(M.is_generating())
            M.generate_docs("function_code", 0, 0)
            assert.is_true(M.is_generating())

            assert.stub(notification_utils.start_spinner_notification).was_called()
            assert.stub(llm_utils.generate_docs).was_called(1)

            local args = llm_utils.generate_docs.calls[1].refs
            assert.equals("string", type(args[1]))
            assert.equals("function", type(args[2]))

            vim.wait(1000, function()
                return M.is_generating() == false
            end, 10)
            assert.is_false(M.is_generating())
        end)

        it("handles successful documentation generation", function()
            local docs = "Generated documentation"
            doc_utils.insert_docs.returns(nil)
            node_utils.get_node_at_position.returns("mock_node")

            simulate_llm_response(docs, nil)

            assert.is_false(M.is_generating())
            M.generate_docs("function_code", 0, 0)
            assert.is_true(M.is_generating())

            wait_for_stub_call(highlight_utils.clear_highlight)

            assert.stub(notification_utils.replace_spinner_notification).was_called_with("Successfully generated docs")
            assert.stub(doc_utils.insert_docs).was_called_with(0, 0, docs)
            assert.stub(highlight_utils.highlight_node).was_called_with("mock_node")
            assert.stub(highlight_utils.clear_highlight).was_called()

            assert.is_false(M.is_generating())
        end)

        it("handles failed documentation generation", function()
            local err = "LLM Error"
            simulate_llm_response(nil, err)

            assert.is_false(M.is_generating())
            M.generate_docs("function_code", 0, 0)
            assert.is_true(M.is_generating())

            wait_for_stub_call(highlight_utils.clear_highlight)

            assert
                .stub(notification_utils.replace_spinner_notification)
                .was_called_with("Could not generate docs: " .. err, true)
            assert.stub(highlight_utils.clear_highlight).was_called()

            assert.is_false(M.is_generating())
        end)

        it("does not highlight if node is nil", function()
            doc_utils.insert_docs.returns(nil)
            node_utils.get_node_at_position.returns(nil)

            local docs = "Generated documentation"
            simulate_llm_response(docs)

            assert.is_false(M.is_generating())
            M.generate_docs("function_code", 0, 0)
            assert.is_true(M.is_generating())

            wait_for_stub_call(notification_utils.replace_spinner_notification)

            assert.stub(highlight_utils.highlight_node).was_not_called()

            assert.is_false(M.is_generating())
        end)

        it("clears highlight after the configured timeout", function()
            local docs = "Generated documentation"
            doc_utils.insert_docs.returns(nil)
            node_utils.get_node_at_position.returns("mock_node")

            simulate_llm_response(docs, nil)
            M.generate_docs("function_code", 0, 0)

            wait_for_stub_call(highlight_utils.highlight_node)
            assert.stub(highlight_utils.highlight_node).was_called_with("mock_node")

            assert.stub(highlight_utils.clear_highlight).was_called(1)

            vim.wait(config.get_config("ui").highlight.timeout + 50)
            assert.stub(highlight_utils.clear_highlight).was_called(2)
        end)

        it("handles error from doc_utils.insert_docs", function()
            local err = "Insertion Error"
            doc_utils.insert_docs.returns(err)

            local docs = "Generated documentation"
            simulate_llm_response(docs, nil)

            assert.is_false(M.is_generating())
            M.generate_docs("function_code", 0, 0)
            assert.is_true(M.is_generating())

            wait_for_stub_call(doc_utils.insert_docs)

            assert.stub(notification_utils.replace_spinner_notification).was_called_with("Successfully generated docs")
            assert.stub(notification_utils.docscribe_notify).was_called_with("Insertion Error", vim.log.levels.ERROR)
            assert.stub(highlight_utils.highlight_node).was_not_called()

            assert.is_false(M.is_generating())
        end)
    end)
end)
