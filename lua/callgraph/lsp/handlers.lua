local Node = require("callgraph.tree.node")
local process_response_errors = require("callgraph.lsp.errors").process_response_errors

local listener = require("callgraph.lsp.listener")

local function process_response(response)
    vim.defer_fn(function()
        listener:finish_request()
    end, 0)
    return process_response_errors(response)
end

---@param uri string
---@param filters string[]
---@param invert_filter boolean
---@return boolean value true if the uri should be filtered out, false otherwise
local function filter_location(uri, filters, invert_filter)
    for _, filter in ipairs(filters) do
        if uri:find(filter or "", 1, true) then
            return not invert_filter
        end
    end
    return invert_filter
end

---@param ctx callgraph.Request.Ctx
---@param uri string
---@return boolean value true if the child should be excluded, false otherwise
local function should_exclude_child(ctx, uri)
    if ctx.root._depth > ctx.opts.depth_limit_out then
        -- vim.notify("Reached depth limit: " .. ctx.opts.depth_limit_out, vim.log.levels.DEBUG)
        return true
    end

    local filter = ctx.opts.filter_location
    if
        type(filter) == "function" and filter(uri)
        or type(filter) == "table" and filter_location(uri, filter, ctx.opts.invert_filter)
    then
        return true
    end

    return false
end

---Replace the root_location in uri with "//"
---@param root_location string
---@param uri string
---@return string file_path relative to the root location
local function short_uri(root_location, uri)
    local location = uri:gsub(root_location or "", "/")
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
        if not should_exclude_child(ctx, call.to.uri) then
            local node = Node.new({
                kind = call.to.kind,
                name = call.to.name,
                location = short_uri(ctx.opts.root_location, call.to.uri),
                call_type = "outgoing",
            }, ctx.root)

            ---Request outgoing calls for call
            ---@type callgraph.Request
            local request = { item = call.to, ctx = { root = node, opts = ctx.opts } }
            cb(client, request, cb)
        end
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
        if not should_exclude_child(ctx, call.from.uri) then
            local node = Node.new({
                kind = call.from.kind,
                name = call.from.name,
                location = short_uri(ctx.opts.root_location, call.from.uri),
                call_type = "incoming",
            }, ctx.root)

            ---Request incoming calls for call
            ---@type callgraph.Request
            local request = { item = call.from, ctx = { root = node, opts = ctx.opts } }
            cb(client, request, cb)
        end
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
        location = short_uri(ctx.opts.root_location, result[1].uri),
        call_type = nil, -- Root node has no call relationship
    }, ctx.root)

    ---Request outgoing or incoming calls based on the direction
    ---@type callgraph.Request
    local request = { item = result[1], ctx = { root = node, opts = ctx.opts } }
    cb(client, request, cb)
end

return M
