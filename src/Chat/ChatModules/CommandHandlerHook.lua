--!strict
---ChatModule hook to invoke the command handler.
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")

local CommandHandler: table = require(ServerScriptService:WaitForChild("CommandHandler"))

return CommandHandler.Run
