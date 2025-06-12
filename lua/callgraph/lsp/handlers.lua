local Node = require("callgraph.tree.node")
local process_response_errors = require("callgraph.lsp.errors").process_response_errors

local listener = require("callgraph.lsp.listener")

local function process_response(response)
    vim.defer_fn(function()
        listener:finish_request()
    end, 0)
    return process_response_errors(response)
end


---@param ctx callgraph.Request.Ctx
---@param uri string
---@return boolean value true if the child should be excluded, false otherwise
local function should_exclude_child(ctx, uri)
    if ctx.root._depth > ctx.opts.depth_limit_out then
        vim.notify("Reached depth limit: " .. ctx.opts.depth_limit_out, vim.log.levels.WARN)
        return true
    end

    if ctx.opts.filter_location(uri) then
        -- vim.notify("Filtered out call to " .. uri, vim.log.levels.TRACE)
        return true
    end

    return false
end

---Replace the root_location in uri with "//"
---@param ctx callgraph.Request.Ctx
---@param uri string
---@return string file_path relative to the root location
local function short_uri(ctx, uri)
    local location = uri:gsub(ctx.opts.root_location or "", "/")
    return location
end

local M = {}

---@type callgraph.Handler
function M.handler_outgoingCalls(response, ctx, cb)
    local client, result = process_response(response)
    if not client or not result then
        vim.notify("Could not process outgoing calls response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyOutgoingCall[]

    --- Process all the outgoing items in the results and request the ougoing calls for they too
    for _, call in ipairs(result) do
        if should_exclude_child(ctx, call.to.uri) then
            goto continue
        end

        local node = Node.new({
            kind = call.to.kind,
            name = call.to.name,
            location = short_uri(ctx, call.to.uri),
            call_type = "outgoing",
        }, ctx.root)

        ---Request outgoing calls for call
        ---@type callgraph.Request
        local request = { item = call.to, ctx = { root = node, opts = ctx.opts } }
        cb(client, request)

        ::continue::
    end
end

---@type callgraph.Handler
function M.handler_incomingCalls(response, ctx, cb)
    local client, result = process_response(response)
    if not client or not result then
        vim.notify("Could not process incoming calls response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyIncomingCall[]

    --- Process all the incoming items in the results and request the incoming calls for they too
    for _, call in ipairs(result) do
        if should_exclude_child(ctx, call.from.uri) then
            goto continue
        end

        local node = Node.new({
            kind = call.from.kind,
            name = call.from.name,
            location = short_uri(ctx, call.from.uri),
            call_type = "incoming",
        }, ctx.root)

        ---Request incoming calls for call
        ---@type callgraph.Request
        local request = { item = call.from, ctx = { root = node, opts = ctx.opts } }
        cb(client, request)

        ::continue::
    end
end

---@type callgraph.Handler
function M.handler_prepareCallHierarchy(response, ctx, cb)
    local client, result = process_response(response)
    if not client or not result or #result == 0 then
        vim.notify("Could not process call hierarchy response", vim.log.levels.ERROR)
        return
    end
    ---@cast result lsp.CallHierarchyItem[]

    --- Extract items from results and put into the tree
    local node = Node.new({
        kind = result[1].kind,
        name = result[1].name,
        location = result[1].uri,
        call_type = nil, -- Root node has no call relationship
    })

    ---Request outgoing or incoming calls based on the direction
    ---@type callgraph.Request
    local request = { item = result[1], ctx = { root = node, opts = ctx.opts } }
    cb(client, request)

    listener:set_on_finish(function()
        vim.notify("Callgraph finished", vim.log.levels.INFO)
        -- vim.print(node:dump_subtree())
        require("callgraph.graph.exporter").export(node, require("callgraph").opts.export)
    end)
end

return M
