# docgen.nvim

## WIP - Not Recommended for Production

_docgen.nvim_ is a plugin for Neovim that generates inline documentation for your code using a Language Model (LLM). It’s designed to help you improve your code documentation in a seamless and automated way, right in your editor.

⚠️ **Warning**: This plugin is currently unstable and actively being worked on. It’s not recommended for production use at the moment, and the features are still in development. If you’re interested in following along or contributing, feel free to check out the code or give it a try, but be aware that there might be bugs and unfinished features.

## Current Features

- **TypeScript/JavaScript Inline Documentation**: Easily generate and insert documentation directly above your TS/JS functions.
- **Real-time Spinner Notifications**: Get a smooth visual feedback with a spinner notification while documentation is being generated.
- **LLM Integration**: The plugin currently supports the Ollama LLM, with any model you like.

## Planned Features

- **Customizable UI**: Choose between inline, popup, or split view for displaying your generated documentation (Inline is the default).
- **Support for more LLMs**: Plug into your preferred language model (LLM) to generate documentation.
- **Support for More Languages**: Expand doc generation support to more programming languages.
- **Advanced Error Handling**: Improve handling of failed or incomplete doc generation.
- **Better Customization Options**: More configurable options for notifications, UI style, and other settings.
- **Timeout Handling**: Add a mechanism to automatically handle generation timeouts.

## Installation

To install `docgen.nvim`, you can use any of the popular Neovim plugin managers. Here are some examples:

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'AdrianMosnegutu/docgen.nvim'
```

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
  'AdrianMosnegutu/docgen.nvim'
})
```

### Using [Vim-Plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'your-github-username/docgen.nvim'
```

### Using [dein.vim](https://github.com/Shougo/dein.vim)

```lua
call dein#add('your-github-username/docgen.nvim')
```

## Usage

### Generating Docs

To generate docs for a function, simply move your cursor to the function and run the command:

```vim
:DocGen
```

The plugin will automatically generate and insert documentation for the function at the cursor.

## Demo

Here’s a quick demo of how the plugin works:

[Screen Recording]

## Current Status

- **Unstable**: Currently in active development.
- **Features**: Basic doc generation, notifications, and UI are functional but still being refined.
- **Planned Features**: Support for more advanced doc generation, better error handling, more customization options.

## Contributing

This is an open project, and I’m always looking for contributions! If you find a bug or have an idea for a new feature, feel free to open an issue or submit a pull request.
