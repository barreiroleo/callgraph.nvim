local handlers = require("callgraph.lsp.handlers")
local listener = require("callgraph.lsp.listener")

---@return vim.lsp.Client?
local function get_client()
    local client = vim.lsp.get_clients({ method = "textDocument/prepareCallHierarchy" })[1]

    if not client then
        vim.notify("No LSP client found for call hierarchy", vim.log.levels.ERROR)
        return nil
    end

    -- vim.notify("Found client " .. client.name, vim.log.levels.TRACE)
    return client
end

local N = {}

---@param dir callgraph.Opts.Run.Dir
---@return callgraph.Requester
function N.select_request(dir)
    if dir == "in" then
        return N.request_incomingCalls
    elseif dir == "out" then
        return N.request_outgoingCalls
    elseif dir == "mix" then
        return function(client, request)
            N.request_incomingCalls(client, request, N.request_incomingCalls)
            N.request_outgoingCalls(client, request, N.request_outgoingCalls)
        end
    else
        error("Invalid direction: " .. dir)
    end
end

---@type callgraph.Requester
function N.request_outgoingCalls(client, request, callback)
    assert(request.item, "callHierarchy/outgoingCalls requires CallHierarchyItem")

    local success, req_id = client:request('callHierarchy/outgoingCalls', { item = request.item },
        function(err, res, ctx, conf)
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_outgoingCalls(response, request.ctx, callback)
        end)

    if not success or not req_id then
        vim.notify("Failed to request outgoing calls", vim.log.levels.ERROR)
        return nil
    end

    listener:new_request(req_id)
    return req_id
end

---@type callgraph.Requester
function N.request_incomingCalls(client, request, callback)
    assert(request.item, "callHierarchy/incomingCalls requires CallHierarchyItem")

    local success, req_id = client:request('callHierarchy/incomingCalls', { item = request.item },
        function(err, res, ctx, conf)
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_incomingCalls(response, request.ctx, callback)
        end)

    if not success or not req_id then
        vim.notify("Failed to request incoming calls", vim.log.levels.ERROR)
        return nil
    end

    listener:new_request(req_id)
    return req_id
end

---@type callgraph.Requester
function N.request_prepareCallHierarchy(client, request, callback)
    assert(request.params, "textDocument/prepareCallHierarchy requires TextDocumentPositionParams")

    local success, req_id = client:request("textDocument/prepareCallHierarchy", request.params,
        function(err, res, ctx, conf)
            local response = { err = err, result = res, context = ctx, config = conf }
            handlers.handler_prepareCallHierarchy(response, request.ctx, callback)
        end)

    if not success or not req_id then
        vim.notify("Failed to request call hierarchy", vim.log.levels.ERROR)
        return nil
    end

    listener:new_request(req_id)
    return req_id
end

local M = {}

---@param opts callgraph.Opts.Run
function M.run(opts)
    require("callgraph")._on_start(opts)

    local client = get_client()
    if not client then
        vim.notify("Failed to run the analysis", vim.log.levels.ERROR)
        return nil
    end

    ---@type callgraph.Request
    local request = {
        params = vim.lsp.util.make_position_params(0, client.offset_encoding),
        ctx = {
            root = nil,
            opts = opts,
        }
    }

    local callback = N.select_request(request.ctx.opts.direction)
    N.request_prepareCallHierarchy(client, request, callback)
end

return M
