local Node = require("callgraph.tree.node")
local process_response = require("callgraph.lsp.errors").process_response
local handlers = require("callgraph.lsp.handlers")

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

---@type callgraph.Requester
local function request_outgoingCalls(client, request)
    assert(request.item, "callHierarchy/outgoingCalls requires CallHierarchyItem")

    local success, req_id = client:request('callHierarchy/outgoingCalls', { item = request.item },
        function(err, res, ctx, conf)
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_outgoingCalls(response, request.ctx, request_outgoingCalls)
        end)

    if not success then
        vim.notify("Failed to request outgoing calls", vim.log.levels.ERROR)
        return nil
    end

    return req_id
end

---@type callgraph.Requester
local function request_incomingCalls(client, request)
    assert(request.item, "callHierarchy/incomingCalls requires CallHierarchyItem")

    local success, req_id = client:request('callHierarchy/incomingCalls', { item = request.item },
        function(err, res, ctx, conf)
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_incomingCalls(response, request.ctx, request_incomingCalls)
        end)

    if not success then
        vim.notify("Failed to request incoming calls", vim.log.levels.ERROR)
        return nil
    end

    return req_id
end

---@type callgraph.Requester
local function request_prepareCallHierarchy(client, request)
    assert(request.params, "textDocument/prepareCallHierarchy requires TextDocumentPositionParams")

    local success, req_id = client:request("textDocument/prepareCallHierarchy", request.params,
        function(err, res, ctx, conf)
            local cb = request.ctx.opts.dir == "in" and request_incomingCalls or request_outgoingCalls
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_prepareCallHierarchy(response, request.ctx, cb)
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
                    dir = "out",
                    depth_limit_in = 10,
                    depth_limit_out = 6,
                    filter_location = "/usr/include/c",
                }
            }
        }
        vim.print(request.ctx)

        request_prepareCallHierarchy(client, request)
    end
}
