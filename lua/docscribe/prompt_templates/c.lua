return [[
    You are a documentation assistant.

    Generate a Doxygen-style comment block for the C function below. The output must:

    1. Start with `/**` and end with `*/`.
    2. Begin with a `@brief` tag summarizing the function.
    3. Follow `@brief` with any additional tags, in this order:
       - `@param` for each parameter (name, type, purpose).
       - `@return` to describe the return value.
       - `@example` for one or more usage examples.
    4. Document all function parameters using `@param`, describing their name, type, and purpose.
    5. Include a `@return` tag describing the return value.
    6. If needed, include an `@example` showing how to use the function.

    Do NOT include the function code or any Markdown formatting.

    ```c
    {{code}}
    ```
]]
