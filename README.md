# callgraph.nvim

A Neovim plugin for visualizing call graphs, based on LSP call hierarchy features.

## Features
- Visualize incoming and outgoing call graphs for functions and methods
- Export call graphs to Graphviz (dot format)
- Custom location filters
- Customizable depth limits (independent for incoming and outgoing)

## Installation

Recommended installation with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "barreiroleo/callgraph.nvim",
  opts = {},
  keys = {
    { '<leader>ci', function() require("callgraph").run({ direction = "in" }) end,  desc = 'Callgraph: incoming calls' },
    { '<leader>co', function() require("callgraph").run({ direction = "out" }) end, desc = 'Callgraph: outgoing calls' },
  },
}
```

## Default Options

```lua
opts = {
  run = {
    depth_limit_in = 10,
    depth_limit_out = 5,
    filter_location = { "/usr/include/c", "/usr/include/c++" },
    -- filter_location = function(uri)
    --   for _, filter in ipairs({ "/usr/include/c", "/usr/include/c++" }) do
    --     if uri:find(filter or "", 1, true) then
    --       vim.notify("Filtered out call to " .. uri, vim.log.levels.TRACE)
    --       return true
    --     end
    --   end
    --   return false
    -- end,
    root_location = vim.uri_from_fname(vim.fn.getcwd()),
  },
  export = {
    file_path = "/tmp/callgraph.dot",
    graph_name = "CallGraph",
    direction = "LR", -- TB, LR, BT, RL
  }
}
```

## Usage

1. Open a file supported by your LSP.
2. Run the analyzer through the Lua API:
   ```lua
   require("callgraph").run({ direction = "in" })
   -- or
   require("callgraph").run({ direction = "out" })
   ```
3. You will receive a notification when the export is complete in your `file_path`.

> **Note:** Command API is planned. You can always write your own custom commands on top of the Lua API.

## Showcase

<!-- Replace with real screenshots or gifs -->
Some examples from the included test project:

![main_outgoing](https://github.com/user-attachments/assets/55824029-9071-49d8-ac15-3725be8250fb)

![main_outgoing_nofilter](https://github.com/user-attachments/assets/0fd03eca-b297-44f9-ad31-2b692d291aa7)

![common_incoming](https://github.com/user-attachments/assets/ada8ddcc-4ca9-4770-82bd-0b88a937a205)


## Requirements
- Neovim 0.12+ (Nightly recommended; not tested on 0.11 stable)
- An LSP server that supports call hierarchy
- A Graphviz dot visualizer of your choice

## Roadmap / Next Steps

- [ ] Open exported file automatically (via xdg or customizable)
- [ ] Call Graphviz to export to other formats
- [ ] Rework the style of the dot exporter
