--- @diagnostic disable: param-type-mismatch, need-check-nil

require("plenary.busted")

describe("docscribe.core.doc", function()
    local doc_utils = require("docscribe.utils.doc")
    local node_utils = require("docscribe.utils.node")

    local bufnr

    before_each(function()
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, bufnr)
        vim.cmd("setfiletype c")
    end)

    after_each(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    describe("get_associated_docs_node", function()
        it("returns nil if the function declaration is on the first line of the buffer", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "int main() {",
                "    return 0;",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 1, 0 })

            local node = node_utils.get_function_node()
            local docs_node = doc_utils.get_associated_docs_node(node)

            assert.is_nil(docs_node)
        end)

        it("returns nil if there is no comment node directly above the function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "/*",
                " * @brief This is the app's entry point",
                "*/",
                "",
                "int main() {",
                "    return 0;",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 5, 0 })

            local node = node_utils.get_function_node()
            local docs_node = doc_utils.get_associated_docs_node(node)

            assert.is_nil(docs_node)
        end)

        it("returns nil if the node directly above the function node is not a comment", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "void test() {",
                "",
                "}",
                "int main() {",
                "    return 0;",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 5, 0 })

            local node = node_utils.get_function_node()
            local docs_node = doc_utils.get_associated_docs_node(node)

            assert.is_nil(docs_node)
        end)

        it("returns the associated docs node for a given function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "/*",
                " * @brief This is the app's entry point",
                "*/",
                "int main() {",
                "    return 0;",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 5, 0 })

            local node = node_utils.get_function_node()
            local docs_node = doc_utils.get_associated_docs_node(node)
            local docs = node_utils.get_node_text(docs_node)

            assert.is_not_nil(docs_node)
            assert.is_equal(docs, "/*\n * @brief This is the app's entry point\n*/")
        end)

        it("returns the associated docs node for an indented function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "class MyClass {",
                "    /**",
                "     * This is a docstring",
                "    */",
                "    function test() {",
                "",
                "    }",
                "}",
            })

            local node = node_utils.get_node_at_position(4, 4)
            local docs_node = doc_utils.get_associated_docs_node(node)
            local docs = node_utils.get_node_text(docs_node)

            assert.is_not_nil(docs_node)
            assert.is_equal(docs, "/**\n     * This is a docstring\n    */")

            local start_row, start_col, end_row, end_col = docs_node:range()
            assert.is_equal(start_row, 1)
            assert.is_equal(start_col, 4)
            assert.is_equal(end_row, 3)
            assert.is_equal(end_col, 6)
        end)

        it("returns the associated one-line comment node for a function node", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "class MyClass {",
                "    // This is a comment",
                "    function test() {",
                "",
                "    }",
                "}",
            })

            local node = node_utils.get_node_at_position(2, 4)
            local docs_node = doc_utils.get_associated_docs_node(node)
            local docs = node_utils.get_node_text(docs_node)

            assert.is_not_nil(docs_node)
            assert.is_equal(docs, "// This is a comment")

            local start_row, start_col, end_row, end_col = docs_node:range()
            assert.is_equal(start_row, 1)
            assert.is_equal(start_col, 4)
            assert.is_equal(end_row, 1)
            assert.is_equal(end_col, 24)
        end)
    end)

    describe("insert_docs", function()
        before_each(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "void test() {",
                "",
                "}",
                "",
                "int main() {",
                "    return 0;",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 5, 0 })
        end)

        it("returns an error message if docs are an empty string", function()
            local err = doc_utils.insert_docs(0, 0, "")

            assert.is_not_nil(err)
            assert.is_equal(err, "Could not insert docs: no docs provided")
        end)

        it("returns an error message if the row is out of bounds", function()
            local err = doc_utils.insert_docs(-1, 0, "Test")

            assert.is_not_nil(err)
            assert.is_equal(err, "Could not insert docs: invalid row")

            err = doc_utils.insert_docs(8, 0, "Test")

            assert.is_not_nil(err)
            assert.is_equal(err, "Could not insert docs: invalid row")
        end)

        it("inserts docs at the specified row", function()
            local docs = "/**\n * @brief This is the app's entry point\n*/"
            local err = doc_utils.insert_docs(4, 0, docs)

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local buffer_text = table.concat(lines, "\n")

            assert.is_nil(err)
            assert.is_equal(
                buffer_text,
                "void test() {\n"
                .. "\n"
                .. "}\n"
                .. "\n"
                .. "/**\n"
                .. " * @brief This is the app's entry point\n"
                .. "*/\n"
                .. "int main() {\n"
                .. "    return 0;\n"
                .. "}"
            )
        end)

        it("inserts docs at the specified row and with the specified indentation level", function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "class MyClass {",
                "    function test() {",
                "",
                "    }",
                "}",
            })
            vim.api.nvim_win_set_cursor(0, { 3, 0 })

            local docs = "/**\n * This is a function\n*/"
            local err = doc_utils.insert_docs(1, 4, docs)

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local buffer_text = table.concat(lines, "\n")

            assert.is_nil(err)
            assert.is_equal(
                buffer_text,
                "class MyClass {\n"
                .. "    /**\n"
                .. "     * This is a function\n"
                .. "    */\n"
                .. "    function test() {\n"
                .. "\n"
                .. "    }\n"
                .. "}"
            )
        end)
    end)
end)
