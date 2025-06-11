---@class callgraph.Config

local M = {}

---@param config callgraph.Config
function M.setup(config)
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        -- require("callgraph.lsp_adapter").test()
        vim.notify("Reloaded callgraph.nvim", vim.log.levels.WARN)
    end, {})
end

return M
