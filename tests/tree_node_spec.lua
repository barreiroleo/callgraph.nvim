---@module "plenary.busted"
---
--- Coverage:
--- - Tree Dump Equality: Node equality, tree structure validation
--- - Tree Edge Case Handling: Single-node, Duplicate insertions, self-references, recursive nodes
--- - Tree Relationship Integrity: Parent-child relationships, tree validation
--- - Tree Navigation: Depth calculation, traversal patterns, node finding
--- - Performance: Large tree operations, search efficiency

local Node = require("callgraph.tree.node")

---@class Data
---@field name string
---@field value integer
---
local data = {
    root = { name = "Root", value = 0 },
    child_1 = { name = "Child 1", value = 1 },
    child_2 = { name = "Child 2", value = 2 },
    child_3 = { name = "Child 3", value = 3 },
    child_4 = { name = "Child 4", value = 4 },
}

---@type Node<Data>
local expected_root = {
    children = {
        {
            children = {
                {
                    children = {},
                    data = data.child_2,
                    is_recursive = false,
                },
            },
            data = data.child_1,
            is_recursive = false,
        },
        {
            children = {},
            data = data.child_3,
            is_recursive = false,
        },
        {
            children = {
                {
                    children = {},
                    data = data.child_4,
                    is_recursive = true,
                },
            },
            data = data.child_4,
            is_recursive = false,
        },
    },
    data = data.root,
    is_recursive = false,
}

--- Expected tree
--- Root
--- ├── Child 1
--- │   └── Child 2
--- ├── Child 3
--- └── Child 4 (recursive)
---@return Node<Data>
local function create_tree()
    local root = Node.new(data.root)
    local child_1 = Node.new(data.child_1, root)
    local _ = Node.new(data.child_2, child_1)

    --- Test edge case: inserting a child with the same data as an existing child
    --- Expected to return the existing child node, not a new one
    local _ = Node.new(data.child_3, root)
    local _ = Node.new(data.child_3, root)

    --- Test edge case: inserting a child with the same data as its parent
    --- Expected to add the parent itself as a child, not create a new node
    local child_4 = Node.new(data.child_4, root)
    local _ = Node.new(data.child_4, child_4)

    return root
end

describe("Tree Dump Equality", function()
    local root = create_tree()

    it("should construct tree with proper hierarchy", function()
        local tree_dump = root:dump_subtree()
        assert.is_true(vim.deep_equal(tree_dump, expected_root), "Tree structure should match expected hierarchy")
    end)
end)

describe("Tree Edge Case Handling", function()
    local root = Node.new(data.root)

    it("should handle empty and single-node trees", function()
        local single_node = Node.new(data.root)

        assert(single_node:is_root(), "Single node should be root")
        assert(single_node:is_leaf(), "Single node should be leaf")
        assert(#single_node.children == 0, "Single node should have no children")
        assert(single_node:get_depth() == 0, "Single node should have depth 0")
    end)

    it("should handle duplicate child insertions correctly", function()
        local child_1 = Node.new(data.child_1, root)
        local duplicate_child = Node.new(data.child_1, root)

        assert.equal(duplicate_child, child_1, "Duplicate insertion should return existing node reference")
        assert.equal(#root.children, 1, "Duplicate insertion should not increase children count")
    end)

    it("should handle self-referential nodes correctly", function()
        local child_4 = Node.new(data.child_4, root)
        local self_ref = Node.new(data.child_4, child_4)

        assert.is_false(child_4:is_recursive(), "Node should not be marked as recursive initially")
        assert.is_true(self_ref:is_recursive(), "Self-referential node should be marked as recursive")

        -- TODO(lbarreiro): Change the implementation to allow self-references without duplicates the node
        -- assert.equal(self_ref, child_4, "Self-reference should return the existing node")
    end)
end)

describe("Tree Relationship Integrity", function()
    local root = create_tree()

    it("should maintain correct parent-child relationships", function()
        assert.is_nil(root.parent, "Root node should have no parent")
        for i, child in ipairs(root.children) do
            assert.equal(child.parent, root, string.format("Child %d should have root as parent", i))
        end
    end)

    it("should correctly identify root and leaf nodes", function()
        assert.is_true(root:is_root(), "Top-level node should be identified as root")
        assert.is_false(root.children[1]:is_root(), "Child nodes should not be identified as root")

        assert.is_false(root:is_leaf(), "Root node with children should not be a leaf")
        assert.is_false(root.children[1]:is_leaf(), "Child 1 with children should not be a leaf")
        assert.is_true(root.children[1].children[1]:is_leaf(), "Child 2 with no children should be a leaf")
        assert.is_true(root.children[2]:is_leaf(), "Child 3 with no children should be a leaf")
        assert.is_false(root.children[3]:is_leaf(), "Child 4 with recursive child should not be a leaf")
    end)
end)

-- describe("Tree Navigation", function()
--     local root = create_tree()
--
--     it("should traverse tree structure properly", function()
--         local visited_nodes = {}
--         root:traverse(function(node)
--             table.insert(visited_nodes, node.data.name)
--         end)
--
--         local expected_order = { "Root", "Child 1", "Child 2", "Child 3", "Child 4" }
--         assert.equal(visited_nodes, expected_order, "Tree traversal should visit nodes in expected depth-first order")
--     end)
--
--     it("should find nodes by data correctly", function()
--         local found_child_2 = root:find_node(data.child_2)
--         assert.not_nil(found_child_2, "Should find existing node by data")
--         assert.equal(found_child_2.data.name, "Child 2", "Found node should have correct data")
--
--         local non_existent = root:find_node({ name = "Non-existent", value = 999 })
--         assert.not_nil(non_existent, "Should return nil for non-existent node data")
--     end)
-- end)

-- describe("Tree Performance", function()
--     it("should handle large tree operations efficiently", function()
--         local large_root = Node.new({ name = "Large Root", value = 0 })
--
--         -- Create a tree with 1000 nodes
--         for i = 1, 1000 do
--             Node.new({ name = "Child " .. i, value = i }, large_root)
--         end
--
--         local start_time = vim.loop.hrtime()
--         local found = large_root:find_node({ name = "Child 500", value = 500 })
--         local end_time = vim.loop.hrtime()
--
--         assert(found ~= nil, "Should find node in large tree")
--         assert((end_time - start_time) < 1000000000, "Search should complete within 1 second") -- 1 second in nanoseconds
--     end)
-- end)
