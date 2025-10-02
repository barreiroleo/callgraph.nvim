local function show_help()
    local help_text = [[
Callgraph Plugin Commands:
    :Callgraph add_location - Add current cursor location to callgraph analysis queue
    :Callgraph run          - Run callgraph analysis on queued locations
    :Callgraph help         - Show this help message

Usage examples:
    1. Position cursor on a function/method call
    2. Run :Callgraph add_location to add it to the queue
    3. Repeat for other locations you want to analyze
    4. Run :Callgraph run to generate the callgraph
]]
    vim.notify(help_text, vim.log.levels.INFO, { title = "Callgraph Help" })
end

local completion_store = {
    ["add_location"] = function() require("callgraph").add_location() end,
    ["run"] = function()
        local callgraph = require("callgraph")
        callgraph.run(callgraph.opts.run, callgraph.opts._dev)
    end,
    ["help"] = show_help
}

---Handle Callgraph subcommands
---@param opts table
local function handle_callgraph_command(opts)
    local params = vim.split(opts.args, "%s+", { trimempty = true })
    local subcommand, action = params[1], params[2]
    local subcommand_map = completion_store[subcommand]

    if not subcommand or not subcommand_map then
        vim.notify("Use ':Callgraph help' for available commands", vim.log.levels.ERROR)
        return
    end

    -- Handle simple commands (no action required)
    if type(subcommand_map) == "function" then
        return subcommand_map()
    end

    -- Handle commands with nested actions
    if type(subcommand_map) == "table" then
        local callback = subcommand_map[action]
        if callback and type(callback) == "function" then
            if opts.range > 0 then
                return callback(opts.line1, opts.line2)
            end
            return callback()
        end
    end

    vim.notify("Invalid subcommand or action: " .. opts.args, vim.log.levels.ERROR)
    return nil
end

---Handle command completion for Callgraph commands
---@param ArgLead string Uncompleted argument prefix: :Callgraph add => ArgLead = "add"
---@param CmdLine string Command line content: :Callgraph add_location => "Callgraph add_location"
---@param _ string
local function handle_command_completion(ArgLead, CmdLine, _)
    local args = vim.split(CmdLine, "%s+", { trimempty = true })
    local subcommand = args[2]

    -- Process subcommands
    if (#args == 1 and ArgLead == "") or (#args == 2 and ArgLead ~= "") then
        return vim.tbl_filter(function(cmd)
            return cmd:match("^" .. (ArgLead or ""))
        end, vim.tbl_keys(completion_store))
    end

    -- Process actions
    if (#args == 2 and ArgLead == "") or (#args == 3 and ArgLead ~= "") then
        local subcommand_map = completion_store[subcommand]
        if subcommand_map and type(subcommand_map) == "table" then
            local actions = vim.tbl_keys(subcommand_map)
            return vim.tbl_filter(function(action)
                return action:match("^" .. (ArgLead or ""))
            end, actions)
        end
    end

    return {}
end

vim.api.nvim_create_user_command("Callgraph", handle_callgraph_command, {
    complete = handle_command_completion,
    desc = "Callgraph operations",
    nargs = "*",
})
