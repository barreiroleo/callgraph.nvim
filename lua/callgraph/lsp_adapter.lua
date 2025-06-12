local Node = require("callgraph.tree.node")

---@class callgraph.Entry
---@field kind lsp.SymbolKind
---@field name string
---@field location lsp.URI

---@class callgraph.Opts
---@field dir "in" | "out"
---@field depth_limit_in integer
---@field depth_limit_out integer
---@field filter_location string? location = "file:///usr/include/c%2B%2B/15.1.1/bits/stl_iterator.h",

---@class callgraph.Request.Ctx
---@field root Node<callgraph.Entry>?
---@field opts callgraph.Opts

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

local M = {}

---@type callgraph.Handler
function M.handler_outgoingCalls(response, ctx)
    local client, result = process_response(response)
    if not client or not result then
        vim.notify("Could not process outgoing calls response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyOutgoingCall[]

    --- Process all the outgoing items in the results and request the ougoing calls for they too
    for _, call in ipairs(result) do
        local node = Node.new({
            kind = call.to.kind,
            name = call.to.name,
            location = call.to.uri,
        }, ctx.root)

        ---@type callgraph.Request
        local request = { item = call.to, ctx = { root = node, opts = ctx.opts } }

        if node.depth == ctx.opts.depth_limit_out then
            vim.notify("Reached depth limit for outgoing calls: " .. ctx.opts.depth_limit_out, vim.log.levels.WARN)
            return
        end

        if node.data.location:find(ctx.opts.filter_location or "", 1, true) then
            vim.notify("Filtered out call to " .. node.data.location, vim.log.levels.DEBUG)
            return
        end

        M.request_outgoingCalls(client, request)
    end

    vim.print(ctx.root)
end

---@type callgraph.Handler
function M.handler_incomingCalls(response, ctx)
    local client, result = process_response(response)
    if not client or not result then
        vim.notify("Could not process incoming calls response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyIncomingCall[]

    --- Process all the incoming items in the results and request the incoming calls for they too
    for _, call in ipairs(result) do
        local node = Node.new({
            kind = call.from.kind,
            name = call.from.name,
            location = call.from.uri,
        }, ctx.root)

        if node.depth == ctx.opts.depth_limit_in then
            vim.notify("Reached depth limit for incoming calls: " .. ctx.opts.depth_limit_in, vim.log.levels.WARN)
            return
        end

        if node.data.location:find(ctx.opts.filter_location or "", 1, true) then
            vim.notify("Filtered out call to " .. node.data.location, vim.log.levels.DEBUG)
            return
        end

        ---@type callgraph.Request
        local request = { item = call.from, ctx = { root = node, opts = ctx.opts } }
        M.request_incomingCalls(client, request)
    end

    vim.print(ctx.root)
end

---@type callgraph.Requester
function M.request_outgoingCalls(client, request)
    local success, req_id = client:request('callHierarchy/outgoingCalls', { item = request.item },
        function(err, res, ctx, conf)
            M.handler_outgoingCalls({ err = err, result = res, context = ctx, config = conf }, request.ctx)
        end)
    if not success then
        vim.notify("Failed to request outgoing calls", vim.log.levels.ERROR)
        return nil
    end
    return req_id
end

---@type callgraph.Requester
function M.request_incomingCalls(client, request)
    local success, req_id = client:request('callHierarchy/incomingCalls', { item = request.item },
        function(err, res, ctx, conf)
            M.handler_incomingCalls({ err = err, result = res, context = ctx, config = conf }, request.ctx)
        end)
    if not success then
        vim.notify("Failed to request incoming calls", vim.log.levels.ERROR)
        return nil
    end
    return req_id
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
    local node = Node.new {
        kind = result[1].kind,
        name = result[1].name,
        location = result[1].uri,
    }

    ---@type callgraph.Request
    local request = { item = result[1], ctx = { root = node, opts = ctx.opts } }
    if ctx.opts.dir == "in" then
        M.request_incomingCalls(client, request)
    elseif ctx.opts.dir == "out" then
        M.request_outgoingCalls(client, request)
    else
        vim.notify("Invalid direction: " .. ctx.opts.dir, vim.log.levels.ERROR)
        return
    end
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

        ---@type callgraph.Request
        local request = {
            params = vim.lsp.util.make_position_params(0, client.offset_encoding),
            ctx = {
                root = nil,
                opts = {
                    dir = "in",
                    depth_limit_in = 10,
                    depth_limit_out = 5,
                    filter_location = "/usr/include/c",
                }
            }
        }

        request_prepareCallHierarchy(client, request)
    end
}
