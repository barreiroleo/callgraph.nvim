local M = {}

---@type callgraph.Opts
M.default_opts = {
    dir = "out",
    depth_limit_in = 10,
    depth_limit_out = 6,
    filter_location = "/usr/include/c",
}

---@param opts callgraph.Opts?
function M.merge_opts(opts)
    return vim.tbl_deep_extend("keep", opts or {}, M.default_opts)
end

return M
