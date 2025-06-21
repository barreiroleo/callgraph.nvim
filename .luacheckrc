-- vim: ft=lua tw=80

return {
    ignore = {
        "212", -- Unused argument. Allows _arg_name rather than just _.
        "211", -- Unused variable. Temporal: Need to rework some tests.
    },

    -- Global objects defined by the C code
    read_globals = {
        "vim",
        "Snacks"
    }
}
