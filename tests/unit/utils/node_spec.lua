--- @diagnostic disable: need-check-nil, param-type-mismatch

require("plenary.busted")

local M = require("docscribe.utils.node")

describe("docscribe.core.node", function()
    local bufnr

    before_each(function()
        bufnr = vim.api.nvim_create_buf(false, true)

        vim.api.nvim_win_set_buf(0, bufnr)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "",
            "int main() {",
            "    return 0;",
            "}",
        })

        vim.cmd("setfiletype c")
    end)

    after_each(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    describe("get_function_node", function()
        local function_node_types = {
            "function_declaration",
            "function_definition",
            "function_expression",
            "method_definition",
            "method_declaration",
            "arrow_function",
        }

        it("returns an error message if no function node is selected", function()
            local node, err = M.get_function_node()

            assert.is_nil(node)
            assert.is_not_nil(err)
            assert.equals(err, "Cursord is not inside a function block")
        end)

        it("returns a function node", function()
            vim.api.nvim_win_set_cursor(0, { 2, 5 })
            local node, err = M.get_function_node()

            assert.is_not_nil(node)
            assert.is_nil(err)
            assert.is_true(vim.tbl_contains(function_node_types, node:type()))
        end)

        it("returns the outer most function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "",
                "function test() {",
                "  function inner() {",
                "",
                "  }",
                "}",
            })

            vim.api.nvim_win_set_cursor(0, { 4, 0 })
            local node, err = M.get_function_node()

            assert.is_not_nil(node)
            assert.is_nil(err)
            assert.is_true(vim.tbl_contains(function_node_types, node:type()))

            local start_row, start_col, end_row, end_col = node:range()
            assert.is_equal(start_row, 1)
            assert.is_equal(start_col, 0)
            assert.is_equal(end_row, 5)
            assert.is_equal(end_col, 1)
        end)
    end)

    describe("get_node_text", function()
        it("returns the node's text", function()
            vim.api.nvim_win_set_cursor(0, { 2, 5 })
            local node = M.get_function_node()
            local text, err = M.get_node_text(node)

            assert.is_not_nil(text)
            assert.is_nil(err)
            assert.is_equal(text, "int main() {\n    return 0;\n}")
        end)
    end)

    it("returns an error if the position is out of bounds", function()
        local node, err = M.get_node_at_position(10, 0)

        assert.is_nil(node)
        assert.is_not_nil(err)
        assert.equals(err, "Could not get node at position: position is out of bounds")
    end)

    describe("get_node_at_position", function()
        it("returns an error message if the parser couldn't be created", function()
            vim.cmd("setfiletype testtest")

            local node, err = M.get_node_at_position(0, 0)

            assert.is_nil(node)
            assert.is_not_nil(err)
            assert.is_equal(err, "Could not get node at position: parser is invalid")
        end)

        it("returns the node at a specified position", function()
            vim.cmd("setfiletype c")

            local node, err = M.get_node_at_position(2, 4)
            local node_text = M.get_node_text(node)

            assert.is_not_nil(node)
            assert.is_nil(err)
            assert.is_equal(node_text, "return 0;")
        end)
    end)

    describe("delete_node_rows", function()
        before_each(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "/*",
                " * @brief This is the app's entry point",
                "*/",
                "int main() {",
                "    return 0;",
                "}",
            })
        end)

        it("deletes a given node from the buffer", function()
            local node = M.get_node_at_position(1, 3)
            local err = M.delete_node_rows(node)

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local buffer_text = table.concat(lines, "\n")

            assert.is_nil(err)
            assert.is_equal(buffer_text, "int madin() {\n    return 0;\n}")
        end)
    end)

    describe("jump_to_node_start", function()
        it("jumps to the start of the node", function()
            local node = M.get_node_at_position(2, 2)
            local start_row, start_col = node:range()

            local err = M.jump_to_node_start(node)
            assert.is_nil(err)

            local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
            assert.is_equal(start_row, cursor_row - 2)
            assert.is_equal(start_col, cursor_col)
        end)
    end)

    describe("get_function_identation", function()
        it("returns the correct indentation level for funcitons on same row as other nodes", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "class MyClass {",
                "    export function test() {",
                "",
                "    }",
                "}",
            })

            local node = M.get_node_at_position(2, 0)
            local indentation_level = M.get_function_indentation(node)

            assert.is_equal(indentation_level, 4)
        end)

        it("returns the identation level of the function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "class MyClass {",
                "    function test() {",
                "",
                "    }",
                "}",
            })

            local node = M.get_node_at_position(1, 11)
            local indentation_level = M.get_function_indentation(node)

            assert.is_equal(indentation_level, 5)

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "int main() {",
                "    return 0;",
                "}",
            })

            node = M.get_node_at_position(0, 0)
            indentation_level = M.get_function_indentation(node)

            assert.is_equal(indentation_level, 0)
        end)
    end)
end)
