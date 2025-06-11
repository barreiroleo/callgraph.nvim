---@class Node<T>: { data: T }
---@field parent Node?
---@field children Node[]
---@field depth integer
---@field data `T`
local Node = {}
Node.__index = Node

---@generic T
---@param data T
---@param parent Node?
---@return Node<T>
function Node.new(data, parent)
    local self = setmetatable({}, Node)
    self.children = {}
    self.data = data
    self.depth = parent and parent.depth + 1 or 0
    self.parent = parent

    if parent then
        for _, child in ipairs(parent.children) do
            if vim.deep_equal(child.data, data) then
                -- vim.notify("Found same node in parent's child", vim.log.levels.TRACE)
                return child
            end
        end

        if vim.deep_equal(parent.data, data) then
            -- vim.notify("Found same data as parent, recursive call. Adding itself as child", vim.log.levels.TRACE)
            parent:insert_child(parent)
            return parent
        end

        -- vim.notify("Inserted node as parent's child", vim.log.levels.TRACE)
        parent:insert_child(self)
    end

    return self
end

function Node:insert_child(child)
    self.children[#self.children + 1] = child
end

function Node:is_root()
    return self.parent == nil
end

function Node:is_leaf()
    return #self.children == 0
end

---@return table subtree tree dump
function Node:dump_subtree()
    local result = {
        data = self.data,
        is_recursive = false,
        children = {},
    }

    for _, child in ipairs(self.children) do
        if self == child then
            result.is_recursive = true
        else
            table.insert(result.children, child:dump_subtree())
        end
    end

    return result
end

return Node
