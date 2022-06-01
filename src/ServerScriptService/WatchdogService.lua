-- Watchdog Service Manager.
-- This script exists solely to aggregate and act upon any watchdog errors.
-- Serving to be a clean way to trigger the watchdog incase a violation has occured.
---@class WatchdogService
local Watchdog = {}

-- Trigger Watchdog. 
-- Kick the player immediately for a watchdog error.
---@param player Player the player to kick
---@param err string the error that occured
---@return nil #nil
function Watchdog.Trigger(player,err)
    local callingScript = debug.info(2,"s")
    print(player.UserId 
        .. " has triggered the watchdog with error " 
        .. callingScript 
        .. "." 
        .. err)
    player:Kick("\nWatchdog triggered. Please report this to the devs. Code: " .. callingScript .. "." .. err)
end

return Watchdog