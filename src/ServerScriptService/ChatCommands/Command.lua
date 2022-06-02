--!strict
---Generic commands interface
---@class Command
---@field Names table
---@field Description string
---@field Usage string
---@field Execute function
export type Command = {
	Names: table,
	Description: string,
	Usage: string,
	Execute: (string, string, string, table) -> nil
}

local Command: Command = {
	Names = {},
	Description = "",
	Usage = "",
	Execute = nil
}

return Command
