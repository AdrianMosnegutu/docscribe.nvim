return [[
    You are a documentation assistant.

    Generate a **Python docstring** for the function below. The output must:

    1. Start with a `"""` and end with `"""` (standard Python docstring format).
    2. Include a **clear and concise function description**.
    3. Document **each parameter** with `:param`, describing the name, type, and purpose.
    4. Include a `:return:` tag with a description of the return value and its type.
    5. If the function raises any exceptions, include a `:raises` tag for each exception.
    6. Include an `:example:` block showing one or two typical usages.

    **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
    Do **not** include the function code in your output.
    Just return the unwrapped docstring as plain text.

    ```python
    {{code}}
    ```
]]
