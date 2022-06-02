--!strict
---Serverside chat commands handler system.
---Don't modify this directly, If you need to register a command create a module under ServerScriptService/ChatCommands
---@diagnostic disable-next-line: duplicate-doc-class ## I have no idea why lsp thinks this is a duplicate
---@class CommandHandler
---@field CommandsMap table
---@field Commands table
---@field Run function
local CommandHandler: table = {}

-- Commands mapped by name
---@type table<string, table>
CommandHandler.CommandsMap = {}

-- Array of commands
---@type table<number,table>
CommandHandler.Commands = {}

local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")
local Command = require(ServerScriptService.ChatCommands.Command)

function CommandHandler.Run(ChatService)
	local children: Array<ModuleScript> = ServerScriptService:WaitForChild("ChatCommands"):GetChildren()
	print("Loading " .. #children .. " commands.")
	-- Require all chat command modules
	for i = 1, #children do
		local child: ModuleScript = children[i]
		if child:IsA("ModuleScript") then
			local command: Command.Command = require(child)
			CommandHandler.Commands[#CommandHandler.Commands + 1] = command

			--Insert commands into the command map by *all* aliases
			for c = 1, #command.Names do
				CommandHandler.CommandsMap[command.Names[c]] = command
			end
		end
	end

	local function handleChatMessage(speaker: string, message: string, channel: string)
		-- if message starts with /
		if string.sub(message, 1, 1) == "/" then
			local messageParts: table = string.split(message, " ")
			local commandName: string = messageParts[1]
			commandName = string.sub(commandName, 2)
			local command: Command.Command = CommandHandler.CommandsMap[commandName]

			if not command == nil then
				command.Execute(speaker, message, channel, ChatService)
				return true
			else
				ChatService:GetSpeaker(speaker):SendSystemMessage("Command not found: " .. commandName)
				return true
			end
		end
		return false
	end

	ChatService:RegisterProcessCommandsFunction("commandHandler", handleChatMessage)
end

return CommandHandler
