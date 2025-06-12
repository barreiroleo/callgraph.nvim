local M = {}

---@param response callgraph.Response.Lsp
---@return vim.lsp.Client? client, table? result
function M.process_response_errors(response)
    if not response then
        vim.notify("Bad response", vim.log.levels.ERROR)
        return nil, nil
    end

    if response.err then
        local err_msg = response.err.message or "Unknown LSP error"
        vim.notify("LSP error: " .. err_msg, vim.log.levels.ERROR)
        return nil, nil
    end

    if not response.result then
        vim.notify("No result in response", vim.log.levels.ERROR)
        return nil, nil
    end

    if not response.context or not response.context.client_id then
        vim.notify("Invalid response context", vim.log.levels.ERROR)
        return nil, nil
    end

    local client = vim.lsp.get_client_by_id(response.context.client_id)
    if not client then
        vim.notify("Could not retrieve client from response", vim.log.levels.ERROR)
        return nil, nil
    end

    return client, response.result
end

return M
