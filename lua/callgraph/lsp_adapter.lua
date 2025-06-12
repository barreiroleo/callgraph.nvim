local Node = require("callgraph.tree.node")

---@class callgraph.Entry
---@field kind lsp.SymbolKind
---@field name string
---@field location lsp.URI

---@class callgraph.Request.Ctx
---@field root Node<callgraph.Entry>?
---@field dir "in" | "out"

---@class callgraph.Request
---@field params lsp.TextDocumentPositionParams?
---@field item lsp.CallHierarchyItem?
---@field ctx callgraph.Request.Ctx

---@class callgraph.Response.Lsp
---@field err lsp.ResponseError?
---@field result table
---@field context lsp.HandlerContext
---@field config table?

---@class callgraph.Response
---@field ctx callgraph.Request.Ctx
---@field lsp callgraph.Response.Lsp

---@alias callgraph.Handler fun(response: callgraph.Response.Lsp, ctx_callgraph: callgraph.Request.Ctx): ...any
---@alias callgraph.Requester fun(client: vim.lsp.Client, ctx: callgraph.Request): integer?


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

---@param response callgraph.Response.Lsp
---@return vim.lsp.Client? client, table? result
local function process_response(response)
    if response.err or not response.result then
        vim.notify("Bad repsonse", vim.log.levels.ERROR)
        return nil, nil
    end

    local client = vim.lsp.get_client_by_id(response.context.client_id)
    if not client then
        vim.notify("Could not retrieve client from response", vim.log.levels.ERROR)
        return nil, nil
    end

    if vim.tbl_isempty(response.result) then
        vim.notify("Empty results. May hit a leaf call", vim.log.levels.TRACE)
        return client, {}
    end

    return client, response.result
end


---@type callgraph.Handler
local function handler_prepareCallHierarchy(response, ctx)
    local client, result = process_response(response)
    if not client or not result then
        vim.notify("Could not process call hierarchy response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyItem[]

    --- Extract items from results and put into the tree
    ctx.root.data = {
        kind = result[1].kind, name = result[1].name, location = result[1].uri,
    }

    ---@type callgraph.Request
    local request = { item = result[1], ctx = ctx }
    -- M.request_incomingCalls(client, request)
end

---@type callgraph.Requester
local function request_prepareCallHierarchy(client, request)
    assert(request.params, "textDocument/prepareCallHierarchy requires TextDocumentPositionParams")
    local success, req_id = client:request("textDocument/prepareCallHierarchy", request.params,
        function(err, res, ctx, conf)
            handler_prepareCallHierarchy({ err = err, result = res, context = ctx, config = conf }, request.ctx)
        end)
    if not success then
        vim.notify("Failed to request call hierarchy", vim.log.levels.ERROR)
        return nil
    end
    return req_id
end



return {
    test = function()
        local client = get_client()
        if not client then
            vim.notify("Failed to find recursive calls", vim.log.levels.ERROR)
            return nil
        end

        ---@type Node<callgraph.Entry>
        local root = Node.new({})

        ---@type callgraph.Request
        local request = {
            params = vim.lsp.util.make_position_params(0, client.offset_encoding),
            ctx = {
                dir = "in",
                root = root,
            }
        }

        request_prepareCallHierarchy(client, request)
    end
}
