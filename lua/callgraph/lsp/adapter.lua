local Node = require("callgraph.tree.node")

local lsp_utils = require("callgraph.lsp.utils")
local handlers = require("callgraph.lsp.handlers")
local listener = require("callgraph.lsp.listener")

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

---@param loc_params lsp.TextDocumentPositionParams[]
---@param opts callgraph.Opts.Run
function M.run(loc_params, opts)
    require("callgraph")._on_start(opts)

    local client = lsp_utils.get_client()
    if not client then
        vim.notify("Failed to run the analysis", vim.log.levels.ERROR)
        return nil
    end

    local root = Node.new()

    for _, param in ipairs(loc_params) do
        ---@type callgraph.Request
        local request = {
            params = param,
            ctx = {
                root = root,
                opts = opts,
            }
        }

        local callback = N.select_request(request.ctx.opts.direction)
        N.request_prepareCallHierarchy(client, request, callback)
    end

    listener:set_on_finish(function()
        require("callgraph")._on_finish(root)
    end)
end

return M
