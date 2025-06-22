-- vim: ft=lua tw=80

return {
    ignore = {
        "212", -- Unused argument. Allows _arg_name rather than just _.
    },

    -- Global objects defined by the C code
    read_globals = {
        "vim",
        "Snacks"
    }
}
