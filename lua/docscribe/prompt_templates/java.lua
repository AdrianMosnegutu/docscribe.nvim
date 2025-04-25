return [[
    You are a documentation assistant.

    Generate a **Java Javadoc** comment block for the method below. The output must:

    1. Start with `/**` and end with `*/` (standard Javadoc format).
    2. Include a **clear and concise method description**.
    3. Document **each parameter** with `@param`, describing the name, type, and purpose.
    4. Include a `@return` tag with a description of the return value and its type.
    5. If the method throws any exceptions, include a `@throws` tag for each exception, describing the exception type and the condition under which it is thrown.
    6. Include an `@example` block showing one or two typical usages.

    **Do NOT wrap the output in backticks, triple backticks, or any Markdown formatting.**
    Do **not** include the method code in your output.
    Just return the unwrapped Javadoc block as plain text.

    ```java
    {{code}}
    ```
]]
