require("plenary.busted")

local mock_config = require("tests.mocks.config")

local M = require("docscribe.llm")

describe("docscribe.llm google provider", function()
    it("generates docs successfully with google provider", function()
        mock_config.get_config = function(key)
            if key == "llm" then
                return {
                    provider = "google",
                    provider_opts = {
                        google = {
                            model = "gemini-1.5-flash",
                            api_key = "mock_api_key",
                        },
                    },
                }
            elseif key == "prompt_templates" then
                return {
                    lua = "Here is a Lua template: {{code}}",
                    default = "Default template: {{code}}",
                }
            end
        end

        local code_snippet = "function add(a, b) return a + b end"
        M.generate_docs(code_snippet, function(docs, err_msg)
            assert.is_nil(err_msg)
            assert.is_not_nil(docs)
            assert.are.same(docs, "Mocked documentation response")
        end)
    end)

    it("handles google provider without api key", function()
        mock_config.get_config = function(key)
            if key == "llm" then
                return {
                    provider = "google",
                    provider_opts = {
                        google = {
                            model = "gemini-1.5-flash",
                            api_key = "",
                        },
                    },
                }
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
            assert.is_equal(err_msg, "Google API key is not configured. Set the GOOGLE_API_KEY environment variable.")
        end)
    end)
end)

