local Node = require("callgraph.tree.node")
local process_response = require("callgraph.lsp.errors").process_response

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
        local node = Node.new({
            kind = call.to.kind,
            name = call.to.name,
            location = call.to.uri,
        }, ctx.root)

        if node._depth >= ctx.opts.depth_limit_out then
            vim.notify("Reached depth limit for outgoing calls: " .. ctx.opts.depth_limit_out, vim.log.levels.WARN)
            goto continue
        end

        if node.data.location:find(ctx.opts.filter_location or "", 1, true) then
            vim.notify("Filtered out call to " .. node.data.location, vim.log.levels.DEBUG)
            goto continue
        end

        ---Request outgoing calls for call
        ---@type callgraph.Request
        local request = { item = call.to, ctx = { root = node, opts = ctx.opts } }
        cb(client, request)

        ::continue::
    end

    vim.print(ctx.root:dump_subtree())
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
        local node = Node.new({
            kind = call.from.kind,
            name = call.from.name,
            location = call.from.uri,
        }, ctx.root)

        if node._depth >= ctx.opts.depth_limit_in then
            vim.notify("Reached depth limit for incoming calls: " .. ctx.opts.depth_limit_in, vim.log.levels.WARN)
            goto continue
        end

        if node.data.location:find(ctx.opts.filter_location or "", 1, true) then
            vim.notify("Filtered out call to " .. node.data.location, vim.log.levels.DEBUG)
            goto continue
        end

        ---Request incoming calls for call
        ---@type callgraph.Request
        local request = { item = call.from, ctx = { root = node, opts = ctx.opts } }
        cb(client, request)

        ::continue::
    end

    vim.print(ctx.root:dump_subtree())
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
    local node = Node.new {
        kind = result[1].kind,
        name = result[1].name,
        location = result[1].uri,
    }

    ---Request outgoing or incoming calls based on the direction
    ---@type callgraph.Request
    local request = { item = result[1], ctx = { root = node, opts = ctx.opts } }
    cb(client, request)
end

return M
