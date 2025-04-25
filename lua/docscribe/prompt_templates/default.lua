return [[
    You are a documentation assistant.

    Generate a **proper documentation comment block** for the function below. The output must:

    1. Include a **clear and concise function description**.
    2. Document **each parameter** with the appropriate tags, describing the name, type, and purpose.
    3. Include a **return value** description with the return type and a brief explanation.
    4. If the function throws any exceptions, include an exception tag.
    5. Include an example block showing typical usage.

    **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
    Do **not** include the function code in your output.
    Just return the unwrapped documentation block as plain text.

    ```
    {{code}}
    ```
]]
