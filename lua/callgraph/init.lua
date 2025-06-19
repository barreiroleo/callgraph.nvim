---@module "callgraph.tree.node"
---@module "callgraph.lsp.utils"

local config = require("callgraph.config")
local lsp_utils = require("callgraph.lsp.utils")

local M = {}

---@type callgraph.Opts
M.opts = {}

---@param opts callgraph.Opts?
function M.setup(opts)
    M.opts = config.merge_opts(opts, config.defs)
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
        vim.notify("Location already exists in the list", vim.log.levels.INFO)
        return nil
    end
    vim.notify("Added location", vim.log.levels.INFO)
    table.insert(loc_list, params)
end

---@param opts callgraph.Opts.Run
---@param dev callgraph.Opts.Dev?
function M.run(opts, dev)
    opts = config.merge_opts(opts, M.opts.run)
    dev = config.merge_opts(dev, M.opts._dev)
    if vim.tbl_isempty(loc_list) then
        M.add_location()
    end
    require("callgraph.lsp.adapter").run(loc_list, opts, dev)
    loc_list = {}
end

return M
