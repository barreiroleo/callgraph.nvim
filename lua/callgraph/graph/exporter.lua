---@module "callgraph.tree.node"
---@module "callgraph.lsp._meta"

---@class DotExporter
---@field private _node_counter integer
---@field private _node_ids table<string, string>
---@field private _subgraph_counter integer
local DotExporter = {}
DotExporter.__index = DotExporter

---@return DotExporter
function DotExporter.new()
    local self = setmetatable({}, DotExporter)
    self._node_counter = 0
    self._subgraph_counter = 0
    self._node_ids = {}
    return self
end

---Generate a unique node ID for DOT format
---@param node Node<callgraph.Entry>
---@return string
function DotExporter:_generate_node_id(node)
    local data = node.data
    local key = string.format("%s_%s_%s", data.name or "unknown", data.kind or 0, data.location or "")

    if not self._node_ids[key] then
        self._node_counter = self._node_counter + 1
        self._node_ids[key] = "node" .. self._node_counter
    end

    return self._node_ids[key]
end

---Escape string for DOT format
---@param str string
---@return string
function DotExporter:_escape_string(str)
    local result = str:gsub('"', '\\"')
    result = result:gsub("\n", "\\n")
    result = result:gsub("\r", "\\r")
    return result
end

---Get node label for display
---@param node Node<callgraph.Entry>
---@return string
function DotExporter:_get_node_label(node)
    local data = node.data
    local name = data.name or "unknown"

    -- Extract filename from location for cleaner display
    local file = ""
    if data.location then
        local location_str = tostring(data.location)
        file = location_str:match("([^/]+)$") or location_str
        file = file:gsub("%%2B%%2B", "++") -- Decode URL encoding for C++
    end

    if file ~= "" then
        return string.format("%s\\n(%s)", name, file)
    else
        return name
    end
end

---Get node style based on kind and recursive status
---@param node Node<callgraph.Entry>
---@param is_recursive boolean
---@param is_root boolean?
---@return string
function DotExporter:_get_node_style(node, is_recursive, is_root)
    local kind = node.data.kind or 0
    local style = ""

    -- Special styling for root node
    if is_root then
        style = "shape=box, style=filled, fillcolor=lightcoral"
    -- Different colors/shapes for different symbol kinds
    elseif kind == 6 then -- Method/Function
        style = "shape=box, style=filled, fillcolor=lightblue"
    elseif kind == 12 then -- Function
        style = "shape=ellipse, style=filled, fillcolor=lightgreen"
    else
        style = "shape=box, style=filled, fillcolor=lightgray"
    end

    -- Mark recursive nodes with different border (unless it's the root)
    if is_recursive and not is_root then
        style = style .. ", color=red, penwidth=2"
    end

    return style
end

---Extract file location from node data
---@param node Node<callgraph.Entry>
---@return string
function DotExporter:_get_file_location(node)
    if not node.data.location then
        return "unknown"
    end

    local location_str = tostring(node.data.location)
    local file = location_str:match("([^/]+)$") or location_str
    file = file:gsub("%%2B%%2B", "++") -- Decode URL encoding for C++
    return file
end

---Check if a node is a virtual root node (empty data)
---@param node Node<callgraph.Entry>
---@return boolean
function DotExporter:_is_virtual_root(node)
    local data = node.data
    if not data then
        return true
    end
    -- Check if the node has meaningful data
    return not (data.name or data.kind or data.location)
end

---Collect all nodes and group them by file location
---@param node Node Node data structure
---@param file_groups table<string, table[]> Table to store nodes grouped by file
---@param visited table<string, boolean> Track visited nodes to prevent infinite recursion
---@param skip_current boolean? Whether to skip the current node (for virtual root)
function DotExporter:_collect_nodes_by_file(node, file_groups, visited, skip_current)
    local node_id = self:_generate_node_id(node)

    -- Prevent infinite recursion
    if visited[node_id] then
        return
    end
    visited[node_id] = true

    -- Skip adding the virtual root to the graph
    if not skip_current then
        -- Group node by file location
        local file_location = self:_get_file_location(node)
        if not file_groups[file_location] then
            file_groups[file_location] = {}
        end
        table.insert(file_groups[file_location], {
            node = node,
            node_id = node_id,
        })
    end

    -- Process children
    if node.children and not node:is_recursive() then
        for _, child in ipairs(node.children) do
            self:_collect_nodes_by_file(child, file_groups, visited, false)
        end
    end
end

---Generate a unique subgraph name according to file location
---@param file_location string
---@return string
function DotExporter:_generate_subgraph_name(file_location)
    self._subgraph_counter = self._subgraph_counter + 1
    local clean_name = file_location:gsub("[^%w_]", "_")
    return "cluster_" .. clean_name .. "_" .. self._subgraph_counter
end

---Export edges between nodes (separate from node definitions)
---@param node Node Node data structure
---@param dot_lines string[] Array to append DOT lines to
---@param visited table<string, boolean> Track visited nodes to prevent infinite recursion
---@param skip_current boolean? Whether to skip creating edges from the current node (for virtual root)
function DotExporter:_export_edges(node, dot_lines, visited, skip_current)
    local node_id = self:_generate_node_id(node)

    -- Prevent infinite recursion
    if visited[node_id] then
        return
    end
    visited[node_id] = true

    -- Process children and create edges
    if node.children and not node:is_recursive() then
        for _, child in ipairs(node.children) do
            local child_id = self:_generate_node_id(child)

            -- Skip creating edges from virtual root to its children
            if not skip_current then
                -- Determine arrow direction based on call relationship type
                ---@type callgraph.Entry
                local child_data = child.data
                local call_type = child_data.call_type
                if call_type == "incoming" then
                    -- For incoming calls: child calls parent, so arrow goes child -> parent
                    table.insert(dot_lines, string.format("  %s -> %s;", child_id, node_id))
                else
                    -- For outgoing calls (or unspecified): parent calls child, so arrow goes parent -> child
                    table.insert(dot_lines, string.format("  %s -> %s;", node_id, child_id))
                end
            end

            -- Recursively process child edges
            self:_export_edges(child, dot_lines, visited, false)
        end
    end
end

---Export a Node tree to DOT (Graphviz) format with subgraphs grouped by file location
---@param root_node Node
---@param opts callgraph.Opts.Export
---@return string DOT format string
function DotExporter:export_to_dot(root_node, opts)
    -- Reset state for new export
    self._node_counter = 0
    self._subgraph_counter = 0
    self._node_ids = {}

    local dot_lines = {}

    -- Start digraph
    table.insert(dot_lines, string.format('digraph "%s" {', opts.graph_name))
    table.insert(dot_lines, "  rankdir=" .. opts.direction .. ";")
    table.insert(dot_lines, '  node [fontname="Arial", fontsize=10];')
    table.insert(dot_lines, '  edge [fontname="Arial", fontsize=8];')
    table.insert(dot_lines, "  compound=true;") -- Allow edges between subgraphs
    table.insert(dot_lines, "")

    -- Collect all nodes grouped by file location
    local file_groups = {}
    local visited_collect = {}
    local is_virtual_root = self:_is_virtual_root(root_node)

    if is_virtual_root then
        -- Skip the virtual root node, but collect its children
        visited_collect[self:_generate_node_id(root_node)] = true
        if root_node.children then
            for _, child in ipairs(root_node.children) do
                self:_collect_nodes_by_file(child, file_groups, visited_collect, false)
            end
        end
    else
        self:_collect_nodes_by_file(root_node, file_groups, visited_collect, false)
    end

    -- Create subgraphs for each file
    for file_location, nodes in pairs(file_groups) do
        local subgraph_name = self:_generate_subgraph_name(file_location)

        table.insert(dot_lines, string.format("  subgraph %s {", subgraph_name))
        table.insert(dot_lines, string.format('    label="%s";', self:_escape_string(file_location)))
        table.insert(dot_lines, "    style=filled;")
        table.insert(dot_lines, "    fillcolor=lightgray;")
        table.insert(dot_lines, "    color=black;")
        table.insert(dot_lines, "")

        -- Add nodes for this file
        for _, node_info in ipairs(nodes) do
            local node = node_info.node
            local node_id = node_info.node_id

            local label = self:_escape_string(node.data.name or "unknown") -- Only show name in subgraph
            local is_root = node == root_node

            -- If root is virtual, treat its direct children as roots
            if is_virtual_root and root_node.children then
                for _, child in ipairs(root_node.children) do
                    if child == node then
                        is_root = true
                        break
                    end
                end
            end

            local style = self:_get_node_style(node, node:is_recursive(), is_root)

            table.insert(dot_lines, string.format('    %s [label="%s", %s];', node_id, label, style))
        end

        table.insert(dot_lines, "  }")
        table.insert(dot_lines, "")
    end

    -- Add edges between nodes
    local visited_edges = {}
    if is_virtual_root then
        -- Start edge export from virtual root's children, skipping edges from virtual root
        self:_export_edges(root_node, dot_lines, visited_edges, true)
    else
        self:_export_edges(root_node, dot_lines, visited_edges, false)
    end

    -- End digraph
    table.insert(dot_lines, "}")

    return table.concat(dot_lines, "\n")
end

---Export to DOT file
---@param root_node Node The root node of the tree
---@param opts callgraph.Opts.Export Options for exporting
---@return boolean success, string? error_message
function DotExporter:export_to_file(root_node, opts)
    local dot_content = self:export_to_dot(root_node, opts)

    local file, err = io.open(opts.file_path, "w")
    vim.notify("Exporting graph to " .. opts.file_path, vim.log.levels.INFO)
    if not file then
        return false, "Failed to open file: " .. (err or "unknown error")
    end

    file:write(dot_content)
    file:close()

    return true
end

local exporter = DotExporter.new()

local M = {}

---@param root_node Node The root node of the tree
---@param opts callgraph.Opts.Export? Options for exporting
function M.export(root_node, opts)
    local config = require("callgraph.config")
    opts = config.merge_opts(opts, require("callgraph").opts.export)
    return exporter:export_to_file(root_node, opts)
end

return M
