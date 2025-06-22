---@module "plenary.busted"
---
--- Coverage:
--- - Incoming outgoing call arrows in the graph

local Node = require("callgraph.tree.node")

--- Helper function to read the content of a file
local function read_file_content(file_path)
    local file = io.open(file_path, "r")
    if not file then
        error("Could not open file: " .. file_path)
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Helper function to extract key arrow directions from DOT content
local function extract_arrow_directions(content)
    local arrows = {}
    -- Extract all arrow connections (node -> node patterns)
    for arrow in content:gmatch("(node%d+%s*%->%s*node%d+)") do
        arrows[#arrows + 1] = arrow:gsub("%s+", "")
    end
    table.sort(arrows)
    return arrows
end

-- Helper function to compare generated DOT with expected blob
local function compare_arrow_directions(test_name)
    local gen_arrows = extract_arrow_directions(read_file_content("/tmp/" .. test_name))
    local exp_arrows = extract_arrow_directions(read_file_content("./tests/blobs/" .. test_name))

    local format_assert = function(a, b)
        return "Generated arrows do not match expected arrows:\n"
            .. "Generated: "
            .. vim.inspect(a)
            .. "\nExpected: "
            .. vim.inspect(b)
    end

    assert.is_true(vim.deep_equal(gen_arrows, exp_arrows), format_assert(gen_arrows, exp_arrows))
end

-- Helper function to export a graph and
local function export(root, test_name, graph_name, direction)
    local exporter = require("callgraph.graph.exporter")
    local success = exporter.export(root, {
        file_path = "/tmp/" .. test_name,
        graph_name = graph_name,
        direction = direction,
    })
    assert.is_true(success, "Export should succeed")
end

describe("Graph Arrow Direction", function()
    before_each(function()
        -- Initialize callgraph with default config for testing
        require("callgraph").setup()
    end)

    it("should export outgoing call tree with correct arrow direction", function()
        local test_name = "test_arrow_dir_outgoing.dot"
        -- Create test tree for outgoing calls: A calls B, B calls C
        local location = test_name .. " (should show A -> B -> C)"
        local root_out = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
        local child_b_out = Node.new({ name = "B", kind = 12, location = location, call_type = "outgoing" }, root_out)
        local child_c_out =
            Node.new({ name = "C", kind = 12, location = location, call_type = "outgoing" }, child_b_out)

        export(root_out, test_name, "TestOutgoing", "LR")
        compare_arrow_directions(test_name)
    end)

    it("should export incoming call tree with correct arrow direction", function()
        local test_name = "test_arrow_dir_incoming.dot"
        -- Create test tree for incoming calls: A is called by B, B is called by C
        local location = test_name .. " (should show A <- B <- C)"
        local root_in = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
        local child_b_in = Node.new({ name = "B", kind = 12, location = location, call_type = "incoming" }, root_in)
        local child_c_in = Node.new({ name = "C", kind = 12, location = location, call_type = "incoming" }, child_b_in)

        export(root_in, test_name, "TestIncoming", "LR")
        compare_arrow_directions(test_name)
    end)

    it("should export mixed call tree with correct arrow directions", function()
        local test_name = "test_arrow_dir_mixed.dot"
        -- Create test tree for mixed calls
        local location = test_name .. " (should show A -> B and C -> A)"
        local root_mix = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
        local child_b_mix = Node.new({ name = "B", kind = 12, location = location, call_type = "outgoing" }, root_mix)
        local child_c_mix = Node.new({ name = "C", kind = 12, location = location, call_type = "incoming" }, root_mix)

        export(root_mix, test_name, "TestMixed", "LR")
        compare_arrow_directions(test_name)
    end)
end)
