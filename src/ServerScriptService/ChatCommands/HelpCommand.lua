--!strict
---Help command
-- @class HelpCommand
-- @author yousef

local Command = require(script.Parent.Command)

local HelpCommand: Command.Command = {
	Names = {
		"help",
		"h",
		"cmds",
		"commands",
		"?",
	},
	Description = "Lists available commands or gives you more information about a specific command.",
	Usage = "/help [command]",
	Execute = nil,
}

local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")

local CommandHandler: table = require(ServerScriptService:WaitForChild("CommandHandler"))

-- selene: allow(unused_variable)
function HelpCommand.Execute(player, message, channel, ChatService)
	local messageParts: table = string.split(message, " ")
	local commandName: string = messageParts[2]
	local command: table = CommandHandler.CommandsMap[commandName]

	if command then
		ChatService:GetSpeaker(player)(command.Description, player)
		ChatService:SendSystemMessage("Usage: " .. command.Usage, player)
		if #command.Names > 1 then
			ChatService:SendSystemMessage("Aliases: " .. table.concat(command.Names, ", "), player)
		end
	else
		ChatService:SendSystemMessage("Available commands:", player)
		for cmd in CommandHandler.Commands do
			ChatService:SendSystemMessage("/" .. cmd.Names[1] .. ": " + cmd.Description, player)
		end
	end
end

return HelpCommand
