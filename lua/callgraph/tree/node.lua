--- Create a stable string representation for the data
---@generic T
---@param data T
---@return string
local function create_data_key(data)
    if type(data) == "table" then
        local parts = {}
        for k, v in pairs(data) do
            table.insert(parts, tostring(k) .. ":" .. tostring(v))
        end
        table.sort(parts)
        return table.concat(parts, "|")
    else
        return tostring(data)
    end
end


---@class Node<T>: { data: T }
---@field parent Node?
---@field children Node[]
---@field data `T`
---@field _depth integer
---@field _child_lookup table<string, Node> -- Hash table for O(1) child lookup
---@field _is_recursive boolean? -- Flag for recursive nodes
local Node = {}
Node.__index = Node

---@generic T
---@param data T
---@param parent Node?
---@return Node<T>
function Node.new(data, parent)
    local self = setmetatable({}, Node)
    self.parent = parent
    self.children = {}
    self.data = data
    self._depth = parent and parent._depth + 1 or 0
    self._child_lookup = {}
    self._is_recursive = false

    if parent then
        local data_key = create_data_key(data)

        local existing_child = parent._child_lookup[data_key]
        if existing_child then
            return existing_child
        end

        local parent_key = create_data_key(parent.data)
        if data_key == parent_key then
            self._is_recursive = true
            data_key = create_data_key(self)
        end

        parent:insert_child(self, data_key)
    end

    return self
end

---@param child Node
---@param data_key string?
function Node:insert_child(child, data_key)
    self.children[#self.children + 1] = child

    if not data_key then
        data_key = create_data_key(child.data)
    end
    self._child_lookup[data_key] = child
end

function Node:is_root()
    return self.parent == nil
end

function Node:is_leaf()
    return #self.children == 0
end

function Node:is_recursive()
    return self._is_recursive == true
end

---@return table subtree tree dump
function Node:dump_subtree()
    local result = {
        data = self.data,
        is_recursive = self:is_recursive(),
        children = {},
    }

    for _, child in ipairs(self.children) do
        if child:is_recursive() then
            -- For recursive nodes, just mark them without traversing
            table.insert(result.children, {
                data = child.data,
                is_recursive = true,
                children = {} -- Don't traverse recursive children
            })
        else
            table.insert(result.children, child:dump_subtree())
        end
    end

    return result
end

return Node
