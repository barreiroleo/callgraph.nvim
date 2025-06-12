---@meta
error('Cannot require a meta file')

---@class callgraph.Opts
---@field run callgraph.Opts.Run?
---@field export callgraph.Opts.Export?

---@class callgraph.Opts.Export
---@field file_path string Path to write the DOT file
---@field graph_name string Name for the graph
---@field direction "TB"|"LR"|"BT"|"RL" Direction

---@class callgraph.Opts.Run
---@field direction "in" | "out"
---@field depth_limit_in integer?
---@field depth_limit_out integer?
---@field filter_location string[]? | fun(uri: string)?: boolean
---@field root_location string?

---@class callgraph.Entry
---@field kind lsp.SymbolKind
---@field name string
---@field location lsp.URI

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
