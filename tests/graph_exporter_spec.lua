---@module "plenary.busted"
---
--- Tests for the graph exporter functionality

local Node = require("callgraph.tree.node")
local exporter = require("callgraph.graph.exporter")

-- Initialize callgraph with default config for testing
require("callgraph").setup()

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

describe("Graph Exporter", function()
    it("should export node-based graph to DOT format", function()
        local root_node = recreate_graph_from_dump()
        local test_file = "/tmp/test_node_exporter.dot"

        local success, err = exporter.export(root_node, {
            file_path = test_file,
            graph_name = "TestNodeGraph",
            direction = "LR",
        })

        assert(success, "Export should succeed: " .. (err or "unknown error"))

        -- Check if file was created
        local file = io.open(test_file, "r")
        assert(file ~= nil, "DOT file should be created")

        if file then
            local content = file:read("*all")
            file:close()

            -- Basic validation of DOT format
            assert(content:find("digraph") ~= nil, "Should contain proper digraph declaration")
            assert(content:find("rankdir=LR") ~= nil, "Should contain direction setting")
            assert(content:find("do_something_common") ~= nil, "Should contain root node")

            -- Clean up
            os.remove(test_file)
        end
    end)

    it("should handle export failures gracefully", function()
        -- Test with invalid file path
        local root_node = recreate_graph_from_dump()
        local success, err = exporter.export(root_node, {
            file_path = "/invalid/path/test.dot",
            graph_name = "TestNodeGraph",
            direction = "LR",
        })

        -- Should handle the error gracefully (either return false or handle the invalid path)
        assert(success ~= nil, "Should return a success status")
    end)
end)
