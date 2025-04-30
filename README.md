<div align="center">

# ✨ docscribe.nvim ✨

**A Neovim plugin for effortless inline documentation using Language Models (LLMs)**

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Neovim](https://img.shields.io/badge/Neovim-0.8%2B-green)
![Tests](https://github.com/AdrianMosnegutu/docscribe.nvim/actions/workflows/tests.yml/badge.svg)

</div>

---

## 📚 Table of Contents

- [🎉 v0.1.0 Stable Release](#-v010-stable-release)
- [🎥 Demo](#-demo)
- [✨ Features](#-features)
- [⚙️ Installation](#️-installation)
- [⚙️ Configuration](#️-configuration)
  - [Custom Prompt Templates](#custom-prompt-templates)
  - [LLM Configuration](#llm-configuration)
- [🚀 Usage](#-usage)
  - [Basic Usage](#basic-usage)
  - [Tips for Best Results](#tips-for-best-results)
- [🛣️ Roadmap](#️-roadmap)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)
- [⭐️ Support](#️-support)

## 🎉 v0.1.0 Stable Release

`docscribe.nvim` is now available as a stable v0.1.0 release! Generate high-quality, contextually aware documentation for your code with a single command.

### Supported Languages & LLM Providers

<div style="display: flex; flex-direction: row; justify-content: center; gap: 2rem; align-items: flex-start;">
  <table>
    <thead>
      <tr><th colspan="2">Supported Languages</th></tr>
      <tr><th>Language</th><th>Support Level</th></tr>
    </thead>
    <tbody>
      <tr><td>JavaScript</td><td>✅ Full</td></tr>
      <tr><td>TypeScript</td><td>✅ Full</td></tr>
      <tr><td>C</td><td>✅ Full</td></tr>
      <tr><td>Java</td><td>🟡 Limited</td></tr>
      <tr><td>C++</td><td>🟡 Limited</td></tr>
      <tr><td>Python</td><td>🟡 Limited</td></tr>
    </tbody>
  </table>

  <table>
    <thead>
      <tr><th colspan="2">Supported LLM Providers</th></tr>
      <tr><th>Provider</th><th>Status</th></tr>
    </thead>
    <tbody>
      <tr><td>Ollama</td><td>✅ Supported</td></tr>
      <tr><td>OpenAI</td><td>🚧 Planned</td></tr>
      <tr><td>Anthropic</td><td>🚧 Planned</td></tr>
      <tr><td>Local Heuristics</td><td>🚧 Planned</td></tr>
    </tbody>
  </table>
</div>

---

## 🎥 Demo

See `docscribe.nvim` in action:

![Demo GIF](media/demo.gif)

---

## ✨ Features

- **Function Documentation Generation**  
  Automatically generate and insert documentation for functions with language-specific formatting.
- **LLM-Powered Documentation**  
  Integration with Ollama for intelligent, contextual documentation generation.
- **Multiple Language Support**  
  Dedicated prompt templates optimized for each supported language.
- **Visual Feedback**  
  Real-time spinner notifications and function highlighting during documentation generation.
- **Smart Docstring Management**  
  Automatically replace existing docstrings when regenerating documentation.

---

## ⚙️ Installation

Install `docscribe.nvim` using your favorite Neovim plugin manager:

### [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'AdrianMosnegutu/docscribe.nvim'
```

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'AdrianMosnegutu/docscribe.nvim',
  config = function()
    require('docscribe').setup({
      -- your configuration here
    })
  end
}
```

### [Vim-Plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'AdrianMosnegutu/docscribe.nvim'
```

### [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('AdrianMosnegutu/docscribe.nvim')
```

### Dependencies

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - For parsing code and locating functions
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - For async operations
- [Ollama](https://ollama.ai/) - Local LLM provider (must be installed separately)

---

## ⚙️ Configuration

`docscribe.nvim` provides several configuration options to tailor the plugin to your needs. Below is the default configuration:

````lua
require('docscribe').setup({
    ui = {
        highlight = {
            style = "signature",        -- "signature" | "full" | "none" function highlight
            timeout = 2000,             -- Time (ms) before highlight fades
            bg = "#545454",             -- Highlight background color
        },
    },
    llm = {
        provider = "ollama",            -- Backend used for LLM (currently only "ollama" is supported)
        model = "llama3.2",             -- Model to use with Ollama (any Ollama model works)
    },
    prompt_templates = {                -- Custom prompt templates for each language
        -- Override existing or add new language templates
        javascript = [[
            You are a documentation assistant.

            Generate a **JavaScript JSDoc** comment block for the function below. The output must:

            1. Start with `/**` and end with `*/` (standard JSDoc format).
            2. Include a **clear and concise function description**.
            3. Document **each parameter** with `@param`, describing the name and purpose.
            4. Include a `@returns` tag with a description of the return value.

            Do NOT wrap the output in backticks or any Markdown formatting.
            Do not include the function code in your output.
            Just return the unwrapped JSDoc block as plain text.

            ```javascript
            {{code}}
            ```
        ]],
        -- Add more language templates as needed
    },
})
````

### Custom Prompt Templates

You can provide your own prompt templates for any language by adding them to the `prompt_templates` section of the configuration. Each template must include the `{{code}}` placeholder, which will be replaced with the actual function code during documentation generation.

To customize a template:

1. Create a multiline string with clear instructions for the LLM
2. Include the language-specific formatting requirements
3. Make sure to have the `{{code}}` placeholder within code fences

### LLM Configuration

Currently, `docscribe.nvim` supports Ollama as the LLM provider. You need to have Ollama installed and running on your system. You can use any model available in Ollama by specifying it in the `model` field.

---

## 🚀 Usage

### Basic Usage

1. Position your cursor inside or on a function
2. Run the command:

```vim
:DocscribeGenerate
```

That's it! `docscribe.nvim` will:

- Identify the function
- Generate appropriate documentation based on the language
- Insert the documentation at the correct position
- Show a visual notification of the process

### Tips for Best Results

- For optimal results, ensure your functions have clear parameter names and types
- In JavaScript/TypeScript, using JSDoc-style type hints improves documentation quality
- In C code, including descriptive parameter names enhances the generated documentation

---

## 🛣️ Roadmap

While v0.1.0 provides a stable experience, we have exciting features planned:

- Support for more programming languages
- Integration with additional LLM providers (OpenAI, Anthropic, etc.)
- Customizable documentation styles
- Batch documentation generation for multiple functions

---

## 🤝 Contributing

Contributions are welcome! Whether it's reporting a bug, suggesting a feature, or submitting a pull request, your help is invaluable in shaping the future of `docscribe.nvim`.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

## ⭐️ Support

If you find this project useful, consider giving it a ⭐️ on GitHub to show your support!

---

<div align="center">
Made with ❤️ for the Neovim community
</div>
