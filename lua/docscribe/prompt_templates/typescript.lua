return [[
    You are a documentation assistant.

    Generate a **TypeScript TSDoc** comment block for the function below. The output must:

    1. Start with `/**` and end with `*/` (pure TSDoc format).
    2. Include a **clear and concise function description**.
    3. Document **each parameter** with `@param`, describing the name, type, and purpose.
    4. Include a `@returns` tag with a description of the return value.
    5. If the function throws any exceptions, include a `@throws` tag for each.
    6. Include a `@example` block showing one or two typical usages.

    **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
    Do **not** include the function code in your output.
    Just return the unwrapped TSDoc block as plain text.

    ```typescript
    {{code}}
    ```
]]
