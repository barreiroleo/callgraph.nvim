local Node = require("callgraph.tree.node")

---@class Data
---@field name string
---@field value integer

---@type Node<Data>
local expected_root = {
    children = { {
        children = { {
            children = {},
            data = {
                name = "Child 2",
                value = 2
            },
            is_recursive = false
        } },
        data = {
            name = "Child 1",
            value = 1
        },
        is_recursive = false
    }, {
        children = {},
        data = {
            name = "Child 3",
            value = 3
        },
        is_recursive = false
    }, {
        children = { {
            children = {},
            data = {
                name = "Child 4",
                value = 4
            },
            is_recursive = true
        } },
        data = {
            name = "Child 4",
            value = 4
        },
        is_recursive = false
    } },
    data = {
        name = "Root",
        value = 0
    },
    is_recursive = false
}

--- Expected tree
--- Root
--- ├── Child 1
--- │   └── Child 2
--- ├── Child 3
--- └── Child 4 (recursive)
---@return Node<Data>
local function create_tree()
    ---@type Node<Data>
    local root = Node.new({ name = "Root", value = 0 })
    local child_1 = Node.new({ name = "Child 1", value = 1 }, root)
    local _ = Node.new({ name = "Child 2", value = 2 }, child_1)

    --- Test edge case: inserting a child with the same data as an existing child
    --- Expected to return the existing child node, not a new one
    local _ = Node.new({ name = "Child 3", value = 3 }, root)
    local _ = Node.new({ name = "Child 3", value = 3 }, root)

    --- Test edge case: inserting a child with the same data as its parent
    --- Expected to add the parent itself as a child, not create a new node
    local child_4 = Node.new({ name = "Child 4", value = 4 }, root)
    local _ = Node.new({ name = "Child 4", value = 4 }, child_4)

    return root
end

---@param root Node
---@param print boolean
---@return boolean
local function test_dump(root, print)
    local tree_dump = root:dump_subtree()

    if print then
        vim.print(tree_dump)
    end

    return vim.deep_equal(tree_dump, expected_root)
end

---@param root Node
---@return boolean
local function test_is_root(root)
    return root:is_root()
end

---@param root Node
---@return boolean
local function test_is_leaf(root)
    return root:is_leaf()
end


local root = create_tree()
assert(test_dump(root, true), "Expected tree dump does not match actual tree dump")
assert(test_is_root(root), "Root node should be a root node")
assert(test_is_root(root.children[1]) == false, "Child 1 should not be a root node")
assert(test_is_leaf(root.children[1].children[1]), "Child 2 should be a leaf node")
assert(test_is_leaf(root.children[1]) == false, "Child 1 should be a leaf node")
