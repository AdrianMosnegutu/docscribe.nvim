--- @module "docscribe.prompt_templates.c"

return [[
You are an expert C programmer specializing in writing documentation that follows the Doxygen standard.

Your response must contain ONLY the Doxygen comment block.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate a Doxygen-style comment block for the following C function.

Follow these rules:
1.  Use `/** ... */` for the comment block.
2.  The main description should be a single, brief paragraph.
3.  Use `@param` for parameters and `@return` for the return value.
4.  If the function's logic is complex, add a `@note` section to explain important details or non-obvious usage. Do not use `@example`.
5.  Add a blank line between the main description and the tag sections.

Code:
```c
{{code}}
```
]]
