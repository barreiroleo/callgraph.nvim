local M = {}

---@return vim.lsp.Client?
function M.get_client()
    local client = vim.lsp.get_clients({ method = "textDocument/prepareCallHierarchy" })[1]
    if not client then
        vim.notify("No LSP client found for call hierarchy", vim.log.levels.ERROR)
        return nil
    end
    -- vim.notify("Found client " .. client.name, vim.log.levels.TRACE)
    return client
end

---@param name string
function M.get_client_by_id(name)
    local client = vim.lsp.get_clients({ method = "textDocument/prepareCallHierarchy", name = name })[1]
    if not client then
        vim.notify("No LSP client found with name: " .. name, vim.log.levels.ERROR)
        return nil
    end
    -- vim.notify("Found client " .. client.name, vim.log.levels.TRACE)
    return client
end

---@param id integer
function M.get_client_by_name(id)
    local client = vim.lsp.get_clients({ method = "textDocument/prepareCallHierarchy", id = id })[1]
    if not client then
        vim.notify("No LSP client found with id: " .. id, vim.log.levels.ERROR)
        return nil
    end
    -- vim.notify("Found client " .. client.name, vim.log.levels.TRACE)
    return client
end

return M
