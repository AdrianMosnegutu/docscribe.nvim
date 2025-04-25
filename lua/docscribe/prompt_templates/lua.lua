return [[
    You are a documentation assistant.

    Generate a **Lua docstring** for the function below. The output must:

    1. Start with `---` for each line (standard Lua docstring format).
    2. Include a **clear and concise function description**.
    3. Document **each parameter** with `@param`, including the name, type, and a brief description.
    4. Include a `@return` tag for each return value, with its type and a brief description.
    5. If the function raises any errors, include a `@error` tag with a description of the error.

    **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
    Do **not** include the function code in your output.
    Just return the unwrapped docstring as plain text.

    ```lua
    {{code}}
    ```
]]
