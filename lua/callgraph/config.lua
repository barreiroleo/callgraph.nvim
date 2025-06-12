local M = {}

---@type callgraph.Opts
M.defs = {
    run = {
        direction = "out",
        depth_limit_in = 10,
        depth_limit_out = 6,
        filter_location = "/usr/include/c", -- usr/include/c%2B%2B
        root_location = vim.uri_from_fname(vim.fn.getcwd()),
    },

    export = {
        file_path = "/tmp/",
        graph_name = "CallGraph",
        direction = "LR", -- TB, LR, BT, RL
    }
}

---@param opts table?
function M.merge_opts(opts)
    return vim.tbl_deep_extend("keep", opts or {}, M.defs)
end

return M
