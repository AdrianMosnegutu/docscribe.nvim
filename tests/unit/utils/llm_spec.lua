require("plenary.busted")

local mock_config = require("tests.mocks.config")

local M = require("docscribe.utils.llm")

describe("docscribe.utils.llm", function()
    it("generates docs successfully", function()
        local code_snippet = "function add(a, b) return a + b end"
        M.generate_docs(code_snippet, function(docs, err_msg)
            assert.is_nil(err_msg)
            assert.is_not_nil(docs)
            assert.are.same(docs, "Mocked documentation response")
        end)
    end)

    it("handles errors in generation", function()
        local code_snippet = "mock_error"
        M.generate_docs(code_snippet, function(docs, err_msg)
            assert.is_nil(docs)
            assert.is_not_nil(err_msg)
            assert.is_equal(err_msg, "Error generating Ollama response")
        end)
    end)

    it("handles invalid LLM provider", function()
        mock_config.get_config = function(key)
            if key == "llm" then
                return { provider = "invalid_provider" }
            elseif key == "prompt_templates" then
                return {
                    lua = "Here is a Lua template: {{code}}",
                    default = "Default template: {{code}}",
                }
            end
        end

        local code_snippet = "function add(a, b) return a + b end"
        M.generate_docs(code_snippet, function(docs, err_msg)
            assert.is_nil(docs)
            assert.is_not_nil(err_msg)
            assert.is_equal(err_msg, 'Invalid LLM runner "invalid_provider"')
        end)
    end)
end)
