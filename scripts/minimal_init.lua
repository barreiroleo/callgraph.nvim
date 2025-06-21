vim.cmd([[let &rtp.=','.getcwd()]])

-- Set up 'plenary' only when calling headless Neovim
if #vim.api.nvim_list_uis() == 0 then
    vim.cmd([[set rtp+=./deps/plenary.nvim]])
    vim.cmd [[runtime! plugin/plenary.vim]] -- Makes <cmd>PlenaryBustedDirectory available from makefile
end

-- Set up 'mini.test' only when calling headless Neovim
if #vim.api.nvim_list_uis() == 0 then
    -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
    -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
    vim.cmd([[set rtp+=deps/mini.nvim]])

    require("mini.test").setup()
end
