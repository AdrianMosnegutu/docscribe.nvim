--- @module "docscribe.prompt_templates.lua"

return [[
You are an expert Lua programmer specializing in writing documentation that follows the EmmyLua/LuaDoc standard.

Your response must contain ONLY the LuaDoc comment block.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate a LuaDoc-style comment block for the following Lua function.

Follow these rules:
1.  Use `---` for each line of the comment block.
2.  The main description should be a single, brief paragraph.
3.  Use `@param` for parameters and `@return` for the return value. Include types where appropriate.
4.  Only include a usage example if the function's logic is complex or has important edge cases. The example must be meaningful and demonstrate a non-obvious use case. Use the `@usage` tag for the example.
5.  Add a blank line between the main description and the tag sections.

Code:
```lua
{{code}}
```
]]