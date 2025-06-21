local Node = require("callgraph.tree.node")

local function recreate_graph_from_dump()
    -- Create the root node: do_something_common
    local root = Node.new({
        kind = 12,
        location = "file:///home/leonardo/develop/plugins/callgraph.nvim/test/Observer/Services/ServiceCommon.hpp",
        name = "do_something_common",
    })

    -- Branch 1: do_something_common_nested
    local do_something_common_nested = Node.new({
        kind = 12,
        location = "//test/Observer/Services/ServiceCommon.hpp",
        name = "do_something_common_nested",
    }, root)

    -- Under do_something_common_nested: run_service_b
    local run_service_b_1 = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceB.hpp",
        name = "run_service_b",
    }, do_something_common_nested)

    -- Under run_service_b_1: process (ServiceB)
    local process_b_1 = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceB.hpp",
        name = "process",
    }, run_service_b_1)

    -- Under process_b_1: run_test_b
    local run_test_b_1 = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "run_test_b",
    }, process_b_1)

    -- Under run_test_b_1: main
    local main_1 = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "main",
    }, run_test_b_1)

    -- Branch 2: do_something_comon_recursive (first occurrence)
    local do_something_common_recursive = Node.new({
        kind = 12,
        location = "//test/Observer/Services/ServiceCommon.hpp",
        name = "do_something_comon_recursive",
    }, root)

    -- Under do_something_common_recursive: create a recursive reference
    local recursive_ref = Node.new({
        kind = 12,
        location = "//test/Observer/Services/ServiceCommon.hpp",
        name = "do_something_comon_recursive",
    }, do_something_common_recursive)

    -- Under do_something_common_recursive: run_service_b (second path)
    local run_service_b_2 = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceB.hpp",
        name = "run_service_b",
    }, do_something_common_recursive)

    -- Under run_service_b_2: process (ServiceB)
    local process_b_2 = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceB.hpp",
        name = "process",
    }, run_service_b_2)

    -- Under process_b_2: run_test_b
    local run_test_b_2 = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "run_test_b",
    }, process_b_2)

    -- Under run_test_b_2: main
    local main_2 = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "main",
    }, run_test_b_2)

    -- Branch 3: run_service_a
    local run_service_a = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceA.hpp",
        name = "run_service_a",
    }, root)

    -- Under run_service_a: process (ServiceA)
    local process_a = Node.new({
        kind = 6,
        location = "//test/Observer/Services/ServiceA.hpp",
        name = "process",
    }, run_service_a)

    -- Under process_a: run_test_a
    local run_test_a = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "run_test_a",
    }, process_a)

    -- Under run_test_a: main
    local main_3 = Node.new({
        kind = 12,
        location = "//test/Observer/main.cpp",
        name = "main",
    }, run_test_a)

    return root
end

local function test_node_exporter()
    local root_node = recreate_graph_from_dump()
    vim.print(root_node:dump_subtree())

    -- Test the new exporter
    local success, err = require("callgraph.graph.exporter").export(root_node, {
        file_path = "/tmp/test_node_exporter.dot",
        graph_name = "TestNodeGraph",
        direction = "LR",
    })

    if success then
        print("✓ Successfully exported Node-based graph to /tmp/test_node_exporter.dot")
    else
        print("✗ Failed to export: " .. (err or "unknown error"))
    end

    return root_node
end

test_node_exporter()
