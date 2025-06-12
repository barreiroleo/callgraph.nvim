---@module "callgraph.tree.node"
---
---Expected structure for the `notify_clients` function in the Observer pattern example.
---@type Node[]
return {
    children = { {
        children = { {
            children = { {
                children = {},
                data = {
                    kind = 12,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
                    name = "main"
                },
                is_recursive = false
            } },
            data = {
                kind = 12,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
                name = "run_test_a"
            },
            is_recursive = false
        } },
        data = {
            kind = 6,
            location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceA.hpp",
            name = "process"
        },
        is_recursive = false
    }, {
        children = { {
            children = { {
                children = {},
                data = {
                    kind = 12,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
                    name = "main"
                },
                is_recursive = false
            } },
            data = {
                kind = 12,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
                name = "run_test_b"
            },
            is_recursive = false
        } },
        data = {
            kind = 6,
            location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceB.hpp",
            name = "process"
        },
        is_recursive = false
    } },
    data = {
        kind = 6,
        location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/lib/Bus.hpp",
        name = "notify_clients"
    },
    is_recursive = false
}
