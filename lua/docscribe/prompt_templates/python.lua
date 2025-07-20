--- @module "docscribe.prompt_templates.python"

return [[
You are an expert Python programmer specializing in writing docstrings that follow the PEP 257 standard.

Your response must contain ONLY the docstring.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate a PEP 257-style docstring for the following Python function.

Follow these rules:
1.  Use a triple-quoted string (`"""..."""`) for the docstring.
2.  The main description should be a single, brief paragraph.
3.  Use "Args:" to introduce the parameters and "Returns:" for the return value.
4.  Only include a usage example if the function's logic is complex or has important edge cases. The example must be meaningful and demonstrate a non-obvious use case. Do not show a trivial call.
5.  Add a blank line between the main description and the "Args:" section.

Code:
```python
{{code}}
```
]]