--- @module "docscribe.prompt_templates.default"

return [[
You are an expert programmer tasked with writing clear, concise, and accurate documentation for a given function.

Your response must contain ONLY the documentation block.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate documentation for the following code.

Follow these rules:
1.  The documentation should be a block comment.
2.  The main description should be a single, brief paragraph explaining the function's purpose. Do not describe the parameters or return value in the description.
3.  Use tags (e.g., @param, @return) to describe parameters and return values.
4.  Only include a usage example if the function's logic is complex or has important edge cases. The example must be meaningful and demonstrate a non-obvious use case. Do not show a trivial call.
5.  Add a blank line between the main description and the tag sections.

Code:
```
{{code}}
```
]]
