---@class lsp.Handler
---@alias callgraph.Direction "in" | "out"
---@alias callgraph.HandlerWithDir fun(err: lsp.ResponseError?, result: any, context: lsp.HandlerContext, config?: table, dir: callgraph.Direction): ...any

---@class callgraph.Entry
---@field kind lsp.SymbolKind
---@field name string
---@field location lsp.URI

---@return vim.lsp.Client?
local function get_client()
    local client = vim.lsp.get_clients({ method = "textDocument/prepareCallHierarchy" })[1]

    if not client then
        vim.notify("No LSP client found for call hierarchy", vim.log.levels.ERROR)
        return nil
    end

    vim.notify("Found client " .. client.name, vim.log.levels.TRACE)
    return client
end


---@type callgraph.HandlerWithDir
local function handler_prepareCallHierarchy(err, result, ctx, config, dir)
    ---@cast result lsp.CallHierarchyItem[]
    if err or not result or vim.tbl_isempty(result) then
        vim.notify("Could not prepare call hierarchy", vim.log.levels.ERROR)
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        vim.notify("Could not retrieve client from response", vim.log.levels.ERROR)
        return
    end

    -- vim.print({ "result: ", result })
    --
    -- if dir == "in" then
    --     request_incoming_calls(client, item, handler_incoming_calls)
    -- else
    --     request_outgoing_calls(client, item, handler_outgoing_calls)
    -- end
end


---@param client vim.lsp.Client
---@param direction callgraph.Direction
---@return integer? request_id
local function request_prepareCallHierarchy(client, direction)
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local success, req_id = client:request('textDocument/prepareCallHierarchy', params, function(err, res, ctx, conf)
        handler_prepareCallHierarchy(err, res, ctx, conf, direction)
    end)
    if not success then
        vim.notify("Failed to request call hierarchy", vim.log.levels.ERROR)
        return nil
    end
    return req_id
end


local M = {}
function M.test()
    local client = get_client()

    if not client then
        vim.notify("Failed to find recursive calls", vim.log.levels.ERROR)
        return nil
    end

    local direction = "in" --[[@as callgraph.Direction]]
    request_prepareCallHierarchy(client, direction)
end

return M
