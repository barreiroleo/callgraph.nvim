local function set_keymaps()
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()

        require("callgraph").setup()
        require("callgraph.lsp.adapter").run({ dir = "in" })
    end, {})
end


local M = {}

---@param opts callgraph.Opts
function M.setup(opts)
    vim.notify("Running analysis with opts" .. vim.inspect(opts), vim.log.levels.INFO)
    set_keymaps()
end

return M
