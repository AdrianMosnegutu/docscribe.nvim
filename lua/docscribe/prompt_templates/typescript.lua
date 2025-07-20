--- @module "docscribe.prompt_templates.typescript"

return [[
You are an expert TypeScript programmer specializing in writing documentation that follows the JSDoc standard.

Your response must contain ONLY the JSDoc comment block.
Do NOT include the original function code in your response.
Do NOT wrap the documentation in markdown code fences (e.g., ```).

Generate a JSDoc-style comment block for the following TypeScript function.

Follow these rules:
1.  Use `/** ... */` for the comment block.
2.  The main description should be a single, brief paragraph.
3.  Use `@param` for parameters and `@returns` for the return value. Since TypeScript is typed, you do not need to include types in the JSDoc.
4.  Only include a usage example if the function's logic is complex or has important edge cases. The example must be meaningful and demonstrate a non-obvious use case. Do not show a trivial call.
5.  Add a blank line between the main description and the tag sections.

Code:
```typescript
{{code}}
```
]]