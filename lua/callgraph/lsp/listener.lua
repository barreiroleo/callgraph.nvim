---@class callgraph.Listener
---@field pending_requests table<integer>
---@field completed_requests integer
---@field is_processing boolean
---@field on_finish function
local Listener = {}
Listener.__index = Listener

---@param on_finish function?
---@return callgraph.Listener
function Listener.new(on_finish)
    local self = setmetatable({}, Listener)

    self.pending_requests = {}
    self.completed_requests = 0
    self.is_processing = false
    self.on_finish = on_finish or function()
        vim.notify("Callgraph finished", vim.log.levels.INFO)
    end

    return self
end

---@param id number
function Listener:new_request(id)
    table.insert(self.pending_requests, id)
    vim.notify("New request: #" .. #self.pending_requests, vim.log.levels.TRACE)
    self.is_processing = true
end

function Listener:finish_request()
    self.completed_requests = self.completed_requests + 1
    vim.notify("Request completed: #" .. self.completed_requests, vim.log.levels.TRACE)

    if #self.pending_requests == self.completed_requests then
        self.is_processing = false
        self.on_finish()
        self:reset()
    end
end

---@param on_finish function
function Listener:set_on_finish(on_finish)
    self.on_finish = on_finish
end

function Listener:reset()
    self.pending_requests = {}
    self.completed_requests = 0
    self.is_processing = false
end

local listener = Listener.new()

return listener
