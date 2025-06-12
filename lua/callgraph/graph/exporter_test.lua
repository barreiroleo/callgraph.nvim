local DotExporter = require("callgraph.graph.exporter")

local expected_in_notify_clients = require("callgraph.graph.expected_notify_in")
local expected_out_main = require("callgraph.graph.expected_main_out")

local function test_exporter_in()
    local exporter = DotExporter.new()

    -- Test file export
    local success, err = exporter:export_to_file(expected_in_notify_clients, {
        file_path = "/tmp/test_incoming.dot",
        graph_name = "IncomingCalls",
        direction = "RL", -- Top to Bottom
    })
    if success then
        vim.print("Successfully exported to /tmp/test_incoming.dot")
    else
        vim.print("Failed to export: " .. (err or "unknown error"))
    end
end

local function test_exporter_out()
    local exporter = DotExporter.new()

    -- Test file export
    local success, err = exporter:export_to_file(expected_out_main, {
        file_path = "/tmp/test_outgoing.dot",
        graph_name = "OutgoingCalls",
        direction = "LR", -- Left to Right
    })
    if success then
        vim.print("Successfully exported to /tmp/test_outgoing.dot")
    else
        vim.print("Failed to export: " .. (err or "unknown error"))
    end
end

test_exporter_in()
test_exporter_out()
