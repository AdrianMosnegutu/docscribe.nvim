<div align="center">

# ✨ docscribe.nvim ✨

**A Neovim plugin for effortless inline documentation using Language Models (LLMs)**

</div>

---

## 🚧 Work in Progress – Not Recommended for Production 🚧

`docscribe.nvim` is a cutting-edge Neovim plugin designed to seamlessly generate inline documentation for your code using the power of Language Models (LLMs). Whether you're a seasoned developer or just getting started, docscribe.nvim aims to make documenting your code easier and more efficient.

⚠️ **Important Notice**: This plugin is currently under active development and is not yet stable for production use. Expect bugs, unfinished features, and rapid iterations. Feel free to explore and contribute!

---

## Table of Contents
- [🎥 Demo](#-demo)
- [✨ Features at a Glance](#-features-at-a-glance)
  - [Currently Available 🟢](#currently-available-)
  - [Coming Soon 🚀](#coming-soon-)
- [⚙️ Installation](#️-installation)
  - [Packer.nvim](#packernvim)
  - [Lazy.nvim](#lazynvim)
  - [Vim-Plug](#vim-plug)
  - [dein.vim](#deinvim)
- [⚙️ Configuration](#️-configuration)
- [🚀 Usage](#-usage)
- [📋 Current Status](#-current-status)
- [🤝 Contributing](#-contributing)
- [⭐️ Support](#️-support)

---

## 🎥 Demo

See `docscribe.nvim` in action:

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

Install `docscribe.nvim` using your favorite Neovim plugin manager:

### [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'AdrianMosnegutu/docscribe.nvim'
```

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
  'AdrianMosnegutu/docscribe.nvim'
})
```

### [Vim-Plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'AdrianMosnegutu/docscribe.nvim'
```

### [dein.vim](https://github.com/Shougo/dein.vim)

```lua
call dein#add('AdrianMosnegutu/docscribe.nvim')
```

---

## ⚙️ Configuration

`docscribe.nvim` provides several configuration options to tailor the plugin to your needs. Below are the default configurations:

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

⚠️ **Warning**: The `prompt_template` must include a `{{code}}` placeholder. This placeholder will be replaced by the actual function code during documentation generation. Without it, the plugin will not know where to place the code, leading to unexpected behavior.

You can override any of these configurations in your Neovim setup file to customize the plugin's behavior.

---

## 🚀 Usage

Generating documentation is as simple as moving your cursor to a function and running:

```vim
:DocscribeGenerate
```

Let `docscribe.nvim` handle the rest!

---

## 📋 Current Status

- **Stability**: Experimental and unstable. Use at your own risk.
- **Core Features**: Basic doc generation, notifications, and UI are functional but evolving.
- **Roadmap**: Advanced features like multi-language support, enhanced error handling, and better customization options are on the way.

---

## 🤝 Contributing

Contributions are welcome! Whether it’s reporting a bug, suggesting a feature, or submitting a pull request, your help is invaluable in shaping the future of `docscribe.nvim`. Check out the [issues](https://github.com/AdrianMosnegutu/docscribe.nvim/issues) page to get started.

---

## ⭐️ Support

If you find this project useful, consider giving it a ⭐️ on GitHub to show your support!
