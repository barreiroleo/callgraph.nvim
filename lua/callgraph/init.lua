local function set_keymaps()
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()

        require("callgraph").setup()
        require("callgraph.lsp.adapter").run({ dir = "in" })
    end, {})

    vim.keymap.set("n", "<leader><leader>c", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()

        require("callgraph").setup()
        require("callgraph.lsp.adapter").run({ dir = "out" })
    end, {})
end


local M = {}

---@param opts callgraph.Opts
function M.setup(opts)
    set_keymaps()
end

return M
