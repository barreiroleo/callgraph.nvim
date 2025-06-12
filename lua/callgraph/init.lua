local config = require("callgraph.config")

local function set_debug_keymaps()
    vim.keymap.set("n", "<leader><leader>z", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()
        require("callgraph").setup()
        require("callgraph").run({ direction = "in" })
    end, {})

    vim.keymap.set("n", "<leader><leader>c", function()
        require("lazy.core.loader").reload("callgraph.nvim")
        Snacks.notifier.clear_history()
        require("callgraph").setup()
        require("callgraph").run({ direction = "out" })
    end, {})
end


local M = {}

---@type callgraph.Opts
M.opts = {}

---@param opts callgraph.Opts?
function M.setup(opts)
    M.opts = config.merge_opts(opts, config.defs)
    -- set_debug_keymaps()
end

---@param opts callgraph.Opts.Export
function M._export(opts)
    opts = config.merge_opts(opts, M.opts.export)
end

---@param opts callgraph.Opts.Run
function M.run(opts)
    opts = config.merge_opts(opts, M.opts.run)
    require("callgraph.lsp.adapter").run(opts)
end

return M
