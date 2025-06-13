---@module "callgraph.tree.node"

local config = require("callgraph.config")

local function set_debug_keymaps()
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()
        require("callgraph").setup()
        require("callgraph").run({ direction = "in" })
    end, {})

    vim.keymap.set("n", "<leader><leader>c", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()
        require("callgraph").setup()
        require("callgraph").run({ direction = "out" })
    end, {})
end

local M = {}

---@type callgraph.Opts
M.opts = {}

---@param opts callgraph.Opts?
function M.setup(opts)
    M.opts = config.merge_opts(opts, config.defs)
    -- set_debug_keymaps()
end

function M._on_start(opts)
    if M.opts._dev.on_start then
        M.opts._dev.on_start(opts)
    end
    if M.opts._dev.profiling then
        ---@diagnostic disable-next-line: missing-fields
        Snacks.profiler.start({
            group = "name", sort = "time", structure = true, filter = { def_plugin = "callgraph.nvim" }
        })
    end

    vim.notify("Running callgraph analysis: " .. vim.inspect(opts), vim.log.levels.INFO)
end

---@param root Node
function M._on_finish(root)
    if M.opts._dev.on_finish then
        M.opts._dev.on_finish(root)
    end
    if M.opts._dev.profiling then
        Snacks.profiler.stop({ group = "name", sort = "time", structure = true, filter = { def_plugin = "callgraph.nvim" } })
    end

    vim.notify("Callgraph finished", vim.log.levels.INFO)
    -- vim.print(node:dump_subtree())
    require("callgraph.graph.exporter").export(root, M.opts.export)
end


---@param opts callgraph.Opts.Run
---@param dev callgraph.Opts.Dev?
function M.run(opts, dev)
    opts = config.merge_opts(opts, M.opts.run)
    M.opts._dev = config.merge_opts(dev, M.opts._dev)
    require("callgraph.lsp.adapter").run(opts)
end

return M
