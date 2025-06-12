---@module "callgraph.tree.node"
---
--- Expected output for the main function in the Observer example.
---@type Node[]
return {
    children = { {
        children = { {
            children = {},
            data = {
                kind = 12,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
                name = "run_recursive"
            },
            is_recursive = true
        } },
        data = {
            kind = 12,
            location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
            name = "run_recursive"
        },
        is_recursive = false
    }, {
        children = { {
            children = { {
                children = {},
                data = {
                    kind = 9,
                    location = "file:///usr/include/c%2B%2B/15.1.1/bits/basic_string.h",
                    name = "basic_string<_CharT, _Traits, _Alloc>"
                },
                is_recursive = false
            }, {
                children = { {
                    children = {},
                    data = {
                        kind = 12,
                        location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                        name = "operator<<"
                    },
                    is_recursive = false
                } },
                data = {
                    kind = 6,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/lib/Bus.hpp",
                    name = "notify_clients"
                },
                is_recursive = false
            }, {
                children = { {
                    children = { {
                        children = {},
                        data = {
                            kind = 12,
                            location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                            name = "operator<<"
                        },
                        is_recursive = false
                    } },
                    data = {
                        kind = 12,
                        location =
                        "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceCommon.hpp",
                        name = "do_something_common"
                    },
                    is_recursive = false
                } },
                data = {
                    kind = 6,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceA.hpp",
                    name = "run_service_a"
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
                children = {},
                data = {
                    kind = 12,
                    location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                    name = "operator<<"
                },
                is_recursive = false
            } },
            data = {
                kind = 6,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/lib/Bus.hpp",
                name = "subscribe"
            },
            is_recursive = false
        } },
        data = {
            kind = 12,
            location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
            name = "run_test_a"
        },
        is_recursive = false
    }, {
        children = { {
            children = { {
                children = {},
                data = {
                    kind = 9,
                    location = "file:///usr/include/c%2B%2B/15.1.1/bits/basic_string.h",
                    name = "basic_string<_CharT, _Traits, _Alloc>"
                },
                is_recursive = false
            }, {
                children = { {
                    children = {},
                    data = {
                        kind = 12,
                        location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                        name = "operator<<"
                    },
                    is_recursive = false
                } },
                data = {
                    kind = 6,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/lib/Bus.hpp",
                    name = "notify_clients"
                },
                is_recursive = false
            }, {
                children = { {
                    children = { {
                        children = { {
                            children = {},
                            data = {
                                kind = 12,
                                location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                                name = "operator<<"
                            },
                            is_recursive = false
                        } },
                        data = {
                            kind = 12,
                            location =
                            "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceCommon.hpp",
                            name = "do_something_common"
                        },
                        is_recursive = false
                    } },
                    data = {
                        kind = 12,
                        location =
                        "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceCommon.hpp",
                        name = "do_something_common_nested"
                    },
                    is_recursive = false
                } },
                data = {
                    kind = 6,
                    location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceB.hpp",
                    name = "run_service_b"
                },
                is_recursive = false
            } },
            data = {
                kind = 6,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceB.hpp",
                name = "process"
            },
            is_recursive = false
        }, {
            children = { {
                children = {},
                data = {
                    kind = 12,
                    location = "file:///usr/include/c%2B%2B/15.1.1/bits/ostream.h",
                    name = "operator<<"
                },
                is_recursive = false
            } },
            data = {
                kind = 6,
                location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/lib/Bus.hpp",
                name = "subscribe"
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
        kind = 12,
        location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/main.cpp",
        name = "main"
    },
    is_recursive = false
}
