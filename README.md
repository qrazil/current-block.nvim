<<<<<<< HEAD
# block.nvim
Use blocks to highlight current scope! 
=======
# current-block.nvim

A Neovim plugin that highlights the current code block under the cursor with transparency support.

## Features

- 🎯 Automatically detects and highlights the current code block
- 🎨 Transparency support for seamless integration
- ⚡ Debounced updates for smooth performance
- 🔧 Fully customizable

## Requirements

- Neovim >= 0.8.0

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "qrazil/current-block.nvim",
  config = function()
    require("current-block").setup({
      highlight_group = "CurrentBlock",
      debounce_ms = 100,
      enabled = true,
      blend = 30,  -- 0-100, where 0 is fully transparent
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  "qrazil/current-block.nvim",
  config = function()
    require("current-block").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'qrazil/current-block.nvim'

lua << EOF
require("current-block").setup()
EOF
```

## Configuration

Default configuration:
```lua
require("current-block").setup({
  highlight_group = "CurrentBlock",  -- Highlight group name
  debounce_ms = 100,                 -- Update delay in milliseconds
  enabled = true,                    -- Enable on startup
  blend = 30,                        -- Transparency level (0-100)
})
```

### Custom Colors
```lua
-- After setup, customize the highlight
vim.api.nvim_set_hl(0, 'CurrentBlock', { 
  bg = "#2e3440", 
  blend = 20 
})
```

## Commands

- `:CurrentBlockToggle` - Toggle highlighting on/off
- `:CurrentBlockEnable` - Enable highlighting
- `:CurrentBlockDisable` - Disable highlighting

## How it Works

The plugin detects code blocks based on indentation levels and highlights all lines at the same or deeper indentation level as the current cursor position.

## License

Apache License - see LICENSE file for details
