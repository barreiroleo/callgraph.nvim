# callgraph.nvim

A Neovim plugin for visualizing call graphs, based on LSP call hierarchy features.

## Features
- **Multi-directional analysis**: Visualize incoming, outgoing, or mixed call graphs for functions and methods
- **Smart export to Graphviz**: Export call graphs to DOT format with subgraphs grouped by file location
- **Flexible filtering**: Custom location filters with invert option to include/exclude specific paths
- **Customizable depth limits**: Independent depth control for incoming and outgoing calls
- **Recursive call detection**: Visual highlighting of recursive function calls with special styling
- **Multi-location support**: Analyze call graphs from multiple cursor positions simultaneously
- **Extensible hooks**: Custom callbacks for analysis start and completion events

### Graph Features

The generated DOT files include:
- **File-based subgraphs**: Functions are grouped by their source files
- **Recursive call highlighting**: Recursive functions have red borders
- **Root node emphasis**: Starting functions are highlighted in coral
- **Symbol type styling**: Different colors for functions vs methods
- **Clean labels**: File names and function names for easy reading

## Installation

Recommended installation with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "barreiroleo/callgraph.nvim",
  opts = {},
  keys = {
    { '<leader>ci', function() require("callgraph").run({ direction = "in" }) end,  desc = 'Callgraph: incoming calls' },
    { '<leader>co', function() require("callgraph").run({ direction = "out" }) end, desc = 'Callgraph: outgoing calls' },
    { '<leader>cm', function() require("callgraph").run({ direction = "mix" }) end, desc = 'Callgraph: mixed calls' },
  },
}
```

## Default Options

```lua
opts = {
  run = {
    direction = "in",                -- "in", "out", or "mix" for incoming, outgoing, or both
    depth_limit_in = 10,             -- Maximum depth for incoming calls
    depth_limit_out = 6,             -- Maximum depth for outgoing calls
    filter_location = { "/usr/include/c", "/usr/include/c++" }, -- Paths to filter out
    invert_filter = false,           -- If true, only include paths in filter_location
    root_location = vim.uri_from_fname(vim.fn.getcwd()), -- Root directory for analysis
    -- Alternative: filter_location can be a function for custom filtering
    -- filter_location = function(uri)
    --   for _, filter in ipairs({ "/usr/include/c", "/usr/include/c++" }) do
    --     if uri:find(filter or "", 1, true) then
    --       vim.notify("Filtered out call to " .. uri, vim.log.levels.TRACE)
    --       return true
    --     end
    --   end
    --   return false
    -- end,
  },
  export = {
    file_path = "/tmp/callgraph.dot", -- Output file path
    graph_name = "CallGraph",         -- Name for the generated graph
    direction = "LR",                 -- Graph layout: TB, LR, BT, RL
  },
  _dev = {                            -- Expect breaking changes from this API
    profiling = false,                -- Enable performance profiling
    log_level = vim.log.levels.TRACE, -- Logging level for debugging
    on_start = nil,                   -- Callback when analysis starts: function(opts)
    on_finish = nil,                  -- Callback when analysis finishes: function(root_node)
  }
}
```

## API Reference

### Core Functions

- `require("callgraph").setup(opts)` - Initialize the plugin with configuration
- `require("callgraph").run(opts, dev_opts)` - Run call graph analysis
- `require("callgraph").add_location()` - Add current cursor position to analysis queue

### Configuration Types

- `direction`: `"in"` | `"out"` | `"mix"` - Analysis direction
- `filter_location`: `string[]` or `function(uri: string): boolean` - Location filtering
- `invert_filter`: `boolean` - Whether to invert the filter logic
- `depth_limit_in/out`: `integer` - Maximum analysis depth
- Graph export supports multiple layouts: `"TB"`, `"LR"`, `"BT"`, `"RL"`

## Usage

### Basic Usage

1. Open a file supported by your LSP.
2. Run the analyzer through the Lua API:

   ```lua
   -- Analyze incoming calls
   require("callgraph").run({ direction = "in" })
   
   -- Analyze outgoing calls
   require("callgraph").run({ direction = "out" })
   
   -- Analyze both directions (mixed)
   require("callgraph").run({ direction = "mix" })
   ```

3. You will receive a notification when the export is complete in your `file_path`.

### Advanced Usage

#### Multiple Locations
You can analyze call graphs from multiple cursor positions:

```lua
-- Add current cursor position to analysis queue
require("callgraph").add_location()

-- Move to another function and add it
require("callgraph").add_location()

-- Run analysis for all added locations
require("callgraph").run({ direction = "mix" })
```

#### Custom Filtering
Use `invert_filter` to only include specific paths:

```lua
require("callgraph").run({
  direction = "out",
  filter_location = { "/path/to/my/project" },
  invert_filter = true  -- Only show calls within the specified paths
})
```

#### Custom callbacks and profiling (Development API)

> **Warning:** The `_dev` API is experimental and may have breaking changes.

```lua
require("callgraph").run(
  { direction = "mix" },
  {
    profiling = true,
    on_start = function(opts) 
      vim.notify("Starting analysis with: " .. vim.inspect(opts))
    end,
    on_finish = function(root_node)
      vim.notify("Analysis complete! Root: " .. root_node.data.name)
    end
  }
)
```

> **Note:** Command API is planned. You can always write your own custom commands on top of the Lua API.

## Showcase

<!-- Replace with real screenshots or gifs -->
Some examples from the included test project:

![main_outgoing](https://github.com/user-attachments/assets/55824029-9071-49d8-ac15-3725be8250fb)

![main_outgoing_nofilter](https://github.com/user-attachments/assets/0fd03eca-b297-44f9-ad31-2b692d291aa7)

![common_incoming](https://github.com/user-attachments/assets/ada8ddcc-4ca9-4770-82bd-0b88a937a205)


## Requirements
- Neovim 0.12+ (Nightly recommended; not tested on 0.11 stable)
- An LSP server that supports call hierarchy (e.g., clangd)
- A Graphviz DOT visualizer of your choice (e.g., `xdot` _recomended_, `graphviz`, online viewers)

## Roadmap / Next Steps

- [ ] **Command API**: Implement vim commands
- [ ] **Auto-open exports**: Open exported files automatically (via xdg or customizable)
- [ ] **Multi-format export**: Call Graphviz to export to PNG, SVG formats
- [ ] **Enhanced styling**: Rework and improve the DOT exporter
