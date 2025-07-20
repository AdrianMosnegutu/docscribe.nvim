return {
    get_config = function(key)
        if key == "prompt_templates" then
            return {
                lua = "Here is a Lua template: {{code}}",
                default = "Default template: {{code}}",
            }
        elseif key == "llm" then
            return {
                provider = "ollama",
                provider_opts = {
                    ollama = {
                        model = "mock_model",
                    },
                },
            }
        end
    end,
}
