local M = {}

---@type callgraph.Opts
M.defs = {
    run = {
        direction = "in",
        depth_limit_in = 10,
        depth_limit_out = 6,
        filter_location = { "/usr/include/c", "/usr/include/c++" },
        invert_filter = false,
        root_location = vim.uri_from_fname(vim.fn.getcwd()),
    },

    export = {
        file_path = "/tmp/callgraph.dot",
        graph_name = "CallGraph",
        direction = "LR", -- TB, LR, BT, RL
    },

    _dev = {
        profiling = false,
        log_level = vim.log.levels.TRACE,
        on_start = nil,
        on_finish = nil,
    }
}

---@generic T: table
---@param opts T?
---@param defs T
---@return T
function M.merge_opts(opts, defs)
    return vim.tbl_deep_extend("keep", opts or {}, defs)
end

return M
