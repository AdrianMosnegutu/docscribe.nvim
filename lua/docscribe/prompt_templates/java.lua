--- @module "docscribe.prompt_templates.java"

return [[
You are an expert Java programmer specializing in writing documentation that follows the Javadoc standard.

Your response must contain ONLY the Javadoc comment block.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate a Javadoc-style comment block for the following Java method.

Follow these rules:
1.  Use `/** ... */` for the comment block.
2.  The main description should be a single, brief paragraph.
3.  Use `@param` for parameters, `@return` for the return value, and `@throws` for exceptions.
4.  Only include a usage example if the method's logic is complex or has important edge cases. The example must be meaningful and demonstrate a non-obvious use case. Wrap the example in `{@code ...}`.
5.  Add a blank line between the main description and the tag sections.

Code:
```java
{{code}}
```
]]
