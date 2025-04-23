<div align="center">

# ✨ docgen.nvim ✨

**A Neovim plugin for effortless inline documentation using Language Models (LLMs)**

</div>

---

## 🚧 Work in Progress – Not Recommended for Production 🚧

**docgen.nvim** is a cutting-edge Neovim plugin designed to seamlessly generate inline documentation for your code using the power of Language Models (LLMs). Whether you're a seasoned developer or just starting out, docgen.nvim aims to make documenting your code effortless and efficient—all within your favorite editor.

⚠️ **Important Notice**: This plugin is currently under active development and is not yet stable for production use. Expect bugs, unfinished features, and rapid iterations. Feel free to explore and contribute, but proceed with caution if using in critical workflows.

---

## 🎥 Demo

See docgen.nvim in action:

![Demo GIF](media/demo.gif)

---

## ✨ Features at a Glance

### Currently Available 🟢

- **TypeScript/JavaScript Inline Documentation**  
  Automatically generate and insert documentation above your TS/JS functions.
- **Real-Time Spinner Notifications**  
  Enjoy smooth, visual feedback with a spinner while docs are being generated.
- **LLM Integration**  
  Fully supports the Ollama LLM with customizable model selection.

### Coming Soon 🚀

- **Customizable UI**  
  Choose your preferred display style: inline, popup, or split view.
- **Support for More LLMs**  
  Integrate with your LLM of choice for personalized documentation.
- **Multi-Language Support**  
  Expand functionality to additional programming languages.
- **Advanced Error Handling**  
  Robust mechanisms to manage incomplete or failed doc generation.
- **Enhanced Customization**  
  Fine-tune notifications, UI styles, and other plugin behaviors.
- **Timeout Management**  
  Automatically handle long-running generation processes.

---

## ⚙️ Installation

Install `docgen.nvim` using your favorite Neovim plugin manager:

### [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'AdrianMosnegutu/docgen.nvim'
```

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
  'AdrianMosnegutu/docgen.nvim'
})
```

### [Vim-Plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'AdrianMosnegutu/docgen.nvim'
```

### [dein.vim](https://github.com/Shougo/dein.vim)

```lua
call dein#add('AdrianMosnegutu/docgen.nvim')
```

---

## ⚙️ Configuration

`docgen.nvim` provides several configuration options to tailor the plugin to your needs. Below are the default configurations:

````lua
{
    ui = {
        highlight = "signature", -- What part of the function to highlight: "full", "signature", "none"
        highlight_color = "#545454", -- Default function highlight color used in the UI
    },
    runner = "ollama",         -- Default runner for executing model tasks
    model = "llama3.2",        -- Default model to use for documentation generation
    prompt_template = [[
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
    ]],
}
````

You can override any of these configurations in your Neovim setup file to customize the plugin's behavior.

⚠️ Warning: The `prompt_template` must include a `{{code}}` placeholder. This placeholder will be replaced by the actual function code during documentation generation. Without it, the plugin will not know where to place the code, leading to unexpected behavior.

---

## 🚀 Usage

Generating documentation is as simple as moving your cursor to a function and running:

```vim
:DocGen
```

Let `docgen.nvim` handle the rest!

---

## 📋 Current Status

- **Stability**: Experimental and unstable. Use at your own risk.
- **Core Features**: Basic doc generation, notifications, and UI are functional but evolving.
- **Roadmap**: Advanced features like multi-language support, enhanced error handling, and better customization options are on the way.

---

## 🤝 Contributing

Contributions are welcome! Whether it’s reporting a bug, suggesting a feature, or submitting a pull request, your help is invaluable in shaping the future of `docgen.nvim`. Check out the [issues](https://github.com/AdrianMosnegutu/docgen.nvim/issues) to get started.

---

## ⭐️ Support

If you find this project useful, consider giving it a ⭐️ on GitHub to show your support!
