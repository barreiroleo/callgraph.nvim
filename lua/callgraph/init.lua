---@class callgraph.Config

local M = {}

---@param config callgraph.Config
function M.setup(config)
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        vim.notify("Reloaded callgraph.nvim", vim.log.levels.WARN)
    end, {})
    vim.keymap.set("n", "<leader><leader>c", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()
        vim.notify("Reloaded callgraph.nvim", vim.log.levels.WARN)
        vim.defer_fn(require("callgraph.lsp_adapter").test, 2)
    end, {})
end

return M
