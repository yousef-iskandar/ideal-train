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
		ChatService:GetSpeaker(player):SendSystemMessage(command.Description, channel)
		ChatService:SendSystemMessage("Usage: " .. command.Usage, player)
		if #command.Names > 1 then
			ChatService:GetSpeaker(player):SendSystemMessage("Aliases: " .. table.concat(command.Names, ", "), channel)
		end
	else
		ChatService:GetSpeaker(player):SendSystemMessage("Available commands:", channel)
		for _,cmd in CommandHandler.Commands do
			ChatService:GetSpeaker(player):SendSystemMessage("/" .. cmd.Names[1] .. ": " .. cmd.Description, channel)
		end
	end
end

return HelpCommand
