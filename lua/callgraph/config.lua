---@param uri string
---@param filters string[]
---@return boolean value true if the uri should be filtered out, false otherwise
local function filter_location(uri, filters)
    for _, filter in ipairs(filters) do
        if uri:find(filter or "", 1, true) then
            -- vim.notify("Filtered out call to " .. uri, vim.log.levels.TRACE)
            return true
        end
    end
    return false
end

---Create a filter function that can handle both function and array inputs
---@param filter_input function|string[]
---@return function filter_function
local function create_filter_function(filter_input)
    if type(filter_input) == "function" then
        -- vim.notify("Using provided filter function", vim.log.levels.TRACE)
        return filter_input
    elseif type(filter_input) == "table" then
        -- vim.notify("Using provided filter strings", vim.log.levels.TRACE)
        return function(uri) return filter_location(uri, filter_input) end
    else
        error("filter_location must be either a function or an array of strings")
    end
end

local M = {}

---@type callgraph.Opts
M.defs = {
    run = {
        direction = "in",
        depth_limit_in = 10,
        depth_limit_out = 6,
        filter_location = { "/usr/include/c", "/usr/include/c++" },
        root_location = vim.uri_from_fname(vim.fn.getcwd()),
    },

    export = {
        file_path = "/tmp/callgraph.dot",
        graph_name = "CallGraph",
        direction = "LR", -- TB, LR, BT, RL
    }
}

---@generic T: table
---@param opts T?
---@param defs T
---@return T
function M.merge_opts(opts, defs)
    local merged = vim.tbl_deep_extend("keep", opts or {}, defs)

    if merged.run and merged.run.filter_location then
        merged.run.filter_location = create_filter_function(merged.run.filter_location)
    end

    return merged
end

return M
