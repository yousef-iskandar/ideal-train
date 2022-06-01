---Generic commands interface
---@class Command
---@field Names table
---@field Description string
---@field Usage string
---@field Execute function
local Command = {}

-- All the names and aliases this command may be invoked with
Command.Names = {}
-- A short description of what this command does
Command.Description = ""
-- A string showing the intended way to invoke this command
Command.Usage = ""
---@diagnostic disable-next-line: unused-local
-- selene: allow(unused_variable)
-- The function to call when this command is invoked.
Command.Execute = function(player, message)
	error("Command.Execute not implemented")
end

return Command
