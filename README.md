# simple-resizer.nvim

A Neovim plugin for intuitive window resizing. Resize windows in the direction you want them to grow or shrink, with intelligent neighbor detection.

## Demo
https://github.com/user-attachments/assets/cf57e9e7-6ea1-4383-ba3a-64bfe4ecbb96


## Features

- **Directional resizing**: Resize windows in the direction that feels natural
- **Smart neighbor detection**: Automatically detects adjacent windows and resizes accordingly
- **Consistent behavior**: Predictable resizing whether windows have neighbors or not
- **Lua API**: Simple functions for programmatic control

## Installation

### lazy.nvim (LazyVim)

```lua
{
  "oswaldoleal/simple-resizer.nvim",
  config = function()
    require("simple-resizer").setup()
    -- Default keybindings (Ctrl+Arrow keys) are automatically set up
  end,
}
```

Or with lazy.nvim's lazy-loading on keys:

```lua
{
  "oswaldoleal/simple-resizer.nvim",
  keys = {
    { "<C-Left>", function() require("simple-resizer").resize_left() end, desc = "Resize window left" },
    { "<C-Right>", function() require("simple-resizer").resize_right() end, desc = "Resize window right" },
    { "<C-Up>", function() require("simple-resizer").resize_up() end, desc = "Resize window up" },
    { "<C-Down>", function() require("simple-resizer").resize_down() end, desc = "Resize window down" },
  },
  config = function()
    require("simple-resizer").setup({
      keys = false, -- Disable default keys since lazy.nvim handles them
    })
  end,
}
```

## Configuration

```lua
require("simple-resizer").setup({
  create_commands = true,  -- Set to false to disable :Resize* commands
  resize_step = 2,         -- Number of lines/columns to resize by
  keys = {
    -- Default keybindings (Ctrl + Arrow keys)
    { "<C-Left>", function() require("simple-resizer").resize_left() end, desc = "Resize window left" },
    { "<C-Right>", function() require("simple-resizer").resize_right() end, desc = "Resize window right" },
    { "<C-Up>", function() require("simple-resizer").resize_up() end, desc = "Resize window up" },
    { "<C-Down>", function() require("simple-resizer").resize_down() end, desc = "Resize window down" },
  },
})
```

### Options

- `create_commands` (boolean, default: `true`): Create user commands (`:ResizeLeft`, `:ResizeRight`, `:ResizeUp`, `:ResizeDown`). Set to `false` if you prefer to use only keybindings or the Lua API.
- `resize_step` (number, default: `2`): Number of lines/columns to resize by with each resize operation.
- `keys` (table or false, default: Ctrl+Arrow keys): Keybindings configuration. Set to `false` to disable all default keybindings, or provide a custom table of keybindings.

### Custom Keybindings

You can customize keybindings in several ways:

**Disable default keybindings:**
```lua
require("simple-resizer").setup({
  keys = false,  -- No default keybindings
})
```

**Custom keybindings:**
```lua
require("simple-resizer").setup({
  keys = {
    { "<leader>wh", function() require("simple-resizer").resize_left() end, desc = "Resize left" },
    { "<leader>wl", function() require("simple-resizer").resize_right() end, desc = "Resize right" },
    { "<leader>wk", function() require("simple-resizer").resize_up() end, desc = "Resize up" },
    { "<leader>wj", function() require("simple-resizer").resize_down() end, desc = "Resize down" },
  },
})
```

**Using commands instead of functions:**
```lua
require("simple-resizer").setup({
  keys = {
    { "<C-Left>", "<cmd>ResizeLeft<cr>", desc = "Resize left" },
    { "<C-Right>", "<cmd>ResizeRight<cr>", desc = "Resize right" },
    { "<C-Up>", "<cmd>ResizeUp<cr>", desc = "Resize up" },
    { "<C-Down>", "<cmd>ResizeDown<cr>", desc = "Resize down" },
  },
})
```

**With custom mode:**
```lua
require("simple-resizer").setup({
  keys = {
    { "<C-Left>", function() require("simple-resizer").resize_left() end, mode = "n", desc = "Resize left" },
    -- mode defaults to "n" (normal mode) if not specified
  },
})
```

## Usage

### Default Keybindings

By default, the following keybindings are automatically set up:

- `<C-Left>` (Ctrl+Left Arrow) - Resize window left
- `<C-Right>` (Ctrl+Right Arrow) - Resize window right
- `<C-Up>` (Ctrl+Up Arrow) - Resize window up
- `<C-Down>` (Ctrl+Down Arrow) - Resize window down

You can customize these in the setup configuration (see Configuration section above).

### User Commands

After calling `setup()`, the following commands are available (unless `create_commands` is disabled):

- `:ResizeLeft` - Resize window left
- `:ResizeRight` - Resize window right
- `:ResizeUp` - Resize window up
- `:ResizeDown` - Resize window down

### Lua API

```lua
local resizer = require('simple-resizer')

-- Resize the current window
resizer.resize_left()    -- Move left edge left (or right edge left if no left neighbor)
resizer.resize_right()   -- Move right edge right (or left edge right if no right neighbor)
resizer.resize_up()      -- Move top edge up (or bottom edge up if no top neighbor)
resizer.resize_down()    -- Move bottom edge down (or top edge down if no bottom neighbor)

-- Resize a specific window
resizer.resize_window(win_id, "left")   -- Direction: "left", "right", "up", "down"
resizer.resize_window(0, "right")       -- Use 0 for current window

-- Get visible neighbors of a window
local neighbors = resizer.get_visible_neighbours(0)
-- Returns: { up = {...}, down = {...}, left = {...}, right = {...} }

-- List all visible windows in the current tab
resizer.list_visible_windows()
```

## How It Works

The plugin intelligently resizes windows based on their neighbors:

- **With neighbor in resize direction**: Grows the window in that direction
- **Without neighbor in resize direction**: Shrinks the window from the opposite edge
- **With neighbors on both sides**: Adjusts the window size in the specified direction

This creates an intuitive resizing experience where pressing a direction key moves the window boundary in that direction.

## License

MIT
