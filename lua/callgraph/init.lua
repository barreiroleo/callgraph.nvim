---@module "callgraph.tree.node"
---@module "callgraph.lsp.utils"

local config = require("callgraph.config")
local lsp_utils = require("callgraph.lsp.utils")

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
        Snacks.profiler.start()
    end

    vim.notify("Running callgraph analysis: " .. vim.inspect(opts), vim.log.levels.INFO)
end

---@param root Node
function M._on_finish(root)
    if M.opts._dev.on_finish then
        M.opts._dev.on_finish(root)
    end
    if M.opts._dev.profiling then
        Snacks.profiler.stop({ group = "name", sort = "time", structure = true, filter = { ref_plugin = "callgraph.nvim" } })
    end

    vim.notify("Callgraph finished", vim.log.levels.INFO)
    vim.print(root:dump_subtree())
    require("callgraph.graph.exporter").export(root, M.opts.export)
end


---@type lsp.TextDocumentPositionParams[]
local loc_list = {}
function M.add_location()
    local client = lsp_utils.get_client()
    if not client then
        vim.notify("No LSP compatible found", vim.log.levels.WARN)
        return nil
    end

    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    if vim.tbl_contains(loc_list, function(v) return vim.deep_equal(v, params) end, { predicate = true }) then
        vim.notify("Location already exists in the list", vim.log.levels.WARN)
        return nil
    end
    vim.notify("Added location", vim.log.levels.DEBUG)
    table.insert(loc_list, params)
end

---@param opts callgraph.Opts.Run
---@param dev callgraph.Opts.Dev?
function M.run(opts, dev)
    opts = config.merge_opts(opts, M.opts.run)
    M.opts._dev = config.merge_opts(dev, M.opts._dev)
    if vim.tbl_isempty(loc_list) then
        M.add_location()
    end
    require("callgraph.lsp.adapter").run(loc_list, opts)
    loc_list = {}
end

return M
