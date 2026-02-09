-- Plugin entry point
-- This file is automatically sourced by Neovim

if vim.g.loaded_simple_resizer then
  return
end
vim.g.loaded_simple_resizer = 1

-- User commands are created in the setup() function
-- Users must call require("simple-resizer").setup() to initialize the plugin
