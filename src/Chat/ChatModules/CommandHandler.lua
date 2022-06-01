---Serverside chat commands handler system.
---Don't modify this directly, If you need to register a command create a module under ServerScriptService/ChatCommands
---@class CommandHandler
local CommandHandler = {}

-- Commands mapped by name
CommandHandler.CommandsMap = {}

local ServerScriptService = game:GetService("ServerScriptService")

function CommandHandler.Run(ChatService) 
    local children = ServerScriptService:WaitForChild("ChatCommands"):GetChildren()

    -- Require all chat command modules
    for i = 1, #children do
        local child = children[i]
        if child:IsA("ModuleScript") then
            local command = require(child)

            --Insert commands into the command map by *all* aliases
            for c = 1, #command.Names do
                CommandHandler.CommandsMap[command.Names[c]] = command
            end
        end
    end

    local function handleChatMessage(message, player)
        -- if message starts with /
        if string.sub(message, 1, 1) == "/" then
            local messageParts = string.split(message, " ")
            local commandName = messageParts[1]
            local command = CommandHandler.CommandsMap[commandName]
    
            if command then
                command.Execute(player, message)
                return true
            else
                ChatService:SendSystemMessage("Command not found: " .. commandName, player)
                return true
            end
        end
        return false
    end

    ChatService:RegisterProcessCommandsFunction(handleChatMessage)
end

return CommandHandler.Run