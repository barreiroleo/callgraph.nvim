---@meta
error('Cannot require a meta file')

---@class callgraph.Opts
---@field run callgraph.Opts.Run?
---@field export callgraph.Opts.Export?
---@field _dev callgraph.Opts.Dev?

---@class callgraph.Opts.Dev
---@field profiling boolean? Enable profiling
---@field log_level vim.log.levels? Log level for debugging
---@field on_start fun(opts: callgraph.Opts.Run)? Called when the callgraph request is started
---@field on_finish fun(root: Node)? Called when the callgraph request is finished

---@class callgraph.Opts.Export
---@field file_path string Path to write the DOT file
---@field graph_name string Name for the graph
---@field direction "TB"|"LR"|"BT"|"RL" Direction

---@alias callgraph.Opts.Run.Dir "in" | "out" | "mix"
---@class callgraph.Opts.Run
---@field direction callgraph.Opts.Run.Dir
---@field depth_limit_in integer?
---@field depth_limit_out integer?
---@field filter_location string[]? | fun(uri: string)?: boolean
---@field invert_filter boolean? True only include the results in filter_location
---@field root_location string?
---@field on_start fun(opts: callgraph.Opts.Run)?
---@field on_finish fun(root: Node)?

---@class callgraph.Entry
---@field kind lsp.SymbolKind
---@field name string
---@field location lsp.URI
---@field call_type "outgoing"|"incoming"? The type of call relationship this node represents

---@class callgraph.Request.Ctx
---@field root Node<callgraph.Entry>?
---@field opts callgraph.Opts.Run

---@class callgraph.Request
---@field params lsp.TextDocumentPositionParams?
---@field item lsp.CallHierarchyItem?
---@field ctx callgraph.Request.Ctx

---@class callgraph.Response.Lsp
---@field err lsp.ResponseError?
---@field result table
---@field context lsp.HandlerContext
---@field config table?

---@class callgraph.Response
---@field ctx callgraph.Request.Ctx
---@field lsp callgraph.Response.Lsp

---@alias callgraph.Handler fun(response: callgraph.Response.Lsp, ctx_callgraph: callgraph.Request.Ctx, cb: callgraph.Requester?): ...any
---@alias callgraph.Requester fun(client: vim.lsp.Client, ctx: callgraph.Request): integer?
