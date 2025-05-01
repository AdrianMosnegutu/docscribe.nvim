require("plenary.busted")

local generate_docs_command = require("docscribe.commands.generate_docs")
local config = require("docscribe.config")
local node_utils = require("docscribe.core.node")
local doc_utils = require("docscribe.core.doc")
local generator_utils = require("docscribe.core.generator")
local highlight_utils = require("docscribe.ui.highlights")
local notification_utils = require("docscribe.ui.notifications")
local stub = require("luassert.stub")

local function stub_dependencies()
    stub(generator_utils, "is_generating")
    stub(generator_utils, "generate_docs")
    stub(node_utils, "get_function_node")
    stub(node_utils, "get_node_text")
    stub(node_utils, "jump_to_node_start")
    stub(node_utils, "get_function_indentation")
    stub(node_utils, "delete_node_rows")
    stub(doc_utils, "get_associated_docs_node")
    stub(highlight_utils, "clear_highlight")
    stub(highlight_utils, "highlight_node")
    stub(highlight_utils, "highlight_signature")
    stub(notification_utils, "docscribe_notify")
    stub(config, "get_config", function(_)
        return { highlight = { style = "full" } }
    end)
end

local function revert_stubs()
    generator_utils.is_generating:revert()
    generator_utils.generate_docs:revert()
    node_utils.get_function_node:revert()
    node_utils.get_node_text:revert()
    node_utils.jump_to_node_start:revert()
    node_utils.get_function_indentation:revert()
    node_utils.delete_node_rows:revert()
    doc_utils.get_associated_docs_node:revert()
    highlight_utils.clear_highlight:revert()
    highlight_utils.highlight_node:revert()
    highlight_utils.highlight_signature:revert()
    notification_utils.docscribe_notify:revert()
    config.get_config:revert()
end

describe("docscribe.commands.generate_docs", function()
    local mock_function_node = { range = function() end }
    local mock_docs_node = { range = function() end }

    before_each(function()
        stub_dependencies()

        stub(mock_function_node, "range")
        stub(mock_docs_node, "range")

        mock_function_node.range.returns(5, 4, 7, 4)
    end)

    after_each(function()
        revert_stubs()

        mock_function_node.range:revert()
        mock_docs_node.range:revert()
    end)

    describe("generate_docs_command", function()
        it("notifies if already generating docs", function()
            generator_utils.is_generating.returns(true)

            generate_docs_command.generate_docs_command()

            assert
                .stub(notification_utils.docscribe_notify)
                .was_called_with("Already generating docs for a function!", vim.log.levels.ERROR)
        end)

        it("notifies if no function node is found", function()
            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(nil, "No function node found")

            generate_docs_command.generate_docs_command()

            assert
                .stub(notification_utils.docscribe_notify)
                .was_called_with("No function node found", vim.log.levels.ERROR)
        end)

        it("notifies if function text cannot be retrieved", function()
            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns("mock_function_node")
            node_utils.get_node_text.returns(nil, "Function text could not be retrieved")

            generate_docs_command.generate_docs_command()

            assert
                .stub(notification_utils.docscribe_notify)
                .was_called_with("Function text could not be retrieved", vim.log.levels.ERROR)
        end)

        it("highlights the full function node and generates docs", function()
            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(mock_function_node)
            node_utils.get_node_text.returns("function_code")
            node_utils.get_function_indentation.returns(4)
            node_utils.jump_to_node_start.returns(true)
            doc_utils.get_associated_docs_node.returns(mock_docs_node)

            generate_docs_command.generate_docs_command()

            assert.stub(config.get_config).was_called_with("ui")
            assert.stub(highlight_utils.clear_highlight).was_called()
            assert.stub(highlight_utils.highlight_node).was_called_with(mock_function_node)
            assert.stub(generator_utils.generate_docs).was_called_with("function_code", 5, 4)

            assert.stub(mock_function_node.range).was_called()
        end)

        it("highlights the function signature node and generates docs", function()
            stub(config, "get_config", function(_)
                return { highlight = { style = "signature" } }
            end)

            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(mock_function_node)
            node_utils.get_node_text.returns("function_code")
            node_utils.get_function_indentation.returns(4)
            node_utils.jump_to_node_start.returns(true)
            doc_utils.get_associated_docs_node.returns(mock_docs_node)

            generate_docs_command.generate_docs_command()

            assert.stub(config.get_config).was_called_with("ui")
            assert.stub(highlight_utils.clear_highlight).was_called()
            assert.stub(highlight_utils.highlight_signature).was_called_with(mock_function_node)
            assert.stub(generator_utils.generate_docs).was_called_with("function_code", 5, 4)

            assert.stub(mock_function_node.range).was_called()
        end)

        it("doesn't highlight the function node and generates docs", function()
            stub(config, "get_config", function(_)
                return { highlight = { style = "none" } }
            end)

            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(mock_function_node)
            node_utils.get_node_text.returns("function_code")
            node_utils.get_function_indentation.returns(4)
            node_utils.jump_to_node_start.returns(true)
            doc_utils.get_associated_docs_node.returns(mock_docs_node)

            generate_docs_command.generate_docs_command()

            assert.stub(config.get_config).was_called_with("ui")
            assert.stub(highlight_utils.clear_highlight).was_called()
            assert.stub(highlight_utils.highlight_node).was_not_called()
            assert.stub(highlight_utils.highlight_signature).was_not_called()
            assert.stub(generator_utils.generate_docs).was_called_with("function_code", 5, 4)

            assert.stub(mock_function_node.range).was_called()
        end)

        it("handles Python-specific docstring insertion logic", function()
            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(mock_function_node)
            node_utils.get_node_text.returns("function_code")
            node_utils.get_function_indentation.returns(4)
            node_utils.jump_to_node_start.returns(true)
            doc_utils.get_associated_docs_node.returns(nil)
            vim.bo.filetype = "python"

            generate_docs_command.generate_docs_command()

            assert.stub(generator_utils.generate_docs).was_called_with("function_code", 6, 8)
        end)

        it("deletes old docstring after generating new docs", function()
            generator_utils.is_generating.returns(false)
            node_utils.get_function_node.returns(mock_function_node)
            node_utils.get_node_text.returns("function_code")
            node_utils.get_function_indentation.returns(4)
            node_utils.jump_to_node_start.returns(true)
            doc_utils.get_associated_docs_node.returns(mock_docs_node)

            generate_docs_command.generate_docs_command()

            assert.stub(mock_docs_node.range).was_called()
            assert.stub(node_utils.delete_node_rows).was_called_with(mock_docs_node)
        end)
    end)
end)
