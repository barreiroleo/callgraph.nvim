local Node = require("callgraph.tree.node")
local exporter = require("callgraph.graph.exporter")

local function test_outgoing()
    -- Create test tree for outgoing calls: A calls B, B calls C
    vim.notify("=== Testing OUTGOING call tree ===")
    local location = "test_outgoing.dot (should show A -> B -> C)"
    local root_out = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
    local child_b_out = Node.new({ name = "B", kind = 12, location = location, call_type = "outgoing" }, root_out)
    local child_c_out = Node.new({ name = "C", kind = 12, location = location, call_type = "outgoing" }, child_b_out)

    local success_out = exporter.export(root_out, {
        file_path = "/tmp/test_outgoing.dot",
        graph_name = "TestOutgoing",
        direction = "LR"
    })
    vim.ui.open("/tmp/test_outgoing.dot")
end

local function test_incoming()
    -- Create test tree for incoming calls: A is called by B, B is called by C
    vim.notify("=== Testing INCOMING call tree ===")
    local location = "test_incoming.dot (should show A <- B <- C)"
    local root_in = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
    local child_b_in = Node.new({ name = "B", kind = 12, location = location, call_type = "incoming" }, root_in)
    local child_c_in = Node.new({ name = "C", kind = 12, location = location, call_type = "incoming" }, child_b_in)

    local success_in = exporter.export(root_in, {
        file_path = "/tmp/test_incoming.dot",
        graph_name = "TestIncoming",
        direction = "LR"
    })
    vim.ui.open("/tmp/test_incoming.dot")
end

local function test_mix()
    -- Create test tree for mixed calls
    vim.notify("=== Testing MIXED call tree ===")
    local location = "test_mixed.dot (should show A -> B and C -> A)"
    local root_mix = Node.new({ name = "A", kind = 12, location = location, call_type = nil })
    local child_b_mix = Node.new({ name = "B", kind = 12, location = location, call_type = "outgoing" }, root_mix)
    local child_c_mix = Node.new({ name = "C", kind = 12, location = location, call_type = "incoming" }, root_mix)

    local success_mix = exporter.export(root_mix, {
        file_path = "/tmp/test_mixed.dot",
        graph_name = "TestMixed",
        direction = "LR"
    })
    vim.ui.open("/tmp/test_mixed.dot")
end

test_outgoing()
test_incoming()
test_mix()
