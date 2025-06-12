local DotExporter = require("callgraph.graph.exporter")

local expected_in_notify_clients = require("callgraph.graph.expected_notify_in")
local expected_out_main = require("callgraph.graph.expected_main_out")

-- Test the exporter
local function test_exporter()
    local exporter = DotExporter.new()

    -- print("=== Testing Incoming Calls (notify_clients) ===")
    -- vim.print(exporter:export_to_dot(expected_in_notify_clients, "IncomingCalls_notify_clients"))

    -- print("=== Testing Outgoing Calls (notify_clients) ===")
    -- vim.print(exporter:export_to_dot(expected_out_main, "OutgoingCalls_notify_clients"))

    -- Test file export
    local success, err = exporter:export_to_file(expected_out_main, "/tmp/test_incoming.dot", "IncomingCalls")
    if success then
        print("Successfully exported to /tmp/test_incoming.dot")
    else
        print("Failed to export: " .. (err or "unknown error"))
    end
end

-- Run the test
test_exporter()

return {
    test_exporter = test_exporter,
    expected_in_notify_clients = expected_in_notify_clients,
    expected_out_notify_clients = expected_out_main
}
