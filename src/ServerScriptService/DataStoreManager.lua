-- Module providing management for the DataStoreService.
-- be VERY careful what you muck about in here.
-- you risk mangling user data if you don't do stuff correctly.
-- if you dont know what you're doing, or arent COMPLETELY CERTAIN about it,
-- DONT do it and ask yousef first.
---@class DataStoreManager
local DataStoreManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")

local Utilities = require(ReplicatedFirst:WaitForChild("Utilities"))
local WatchdogService = require(ServerScriptService:WaitForChild("WatchdogService"))

local clientPlayerStore = DataStoreService:GetDataStore("ClientPlayerStore")
local clientPlayerDataCache = {}

local clientPlayerDataTemplate = {
	clientDataVersion = 0,
	oldestCompatibleVersion = 0,
}
local clientPlayerDataTypeLayout = {
	clientDataVersion = "number",
	oldestCompatibleVersion = "number",
}


local serverPlayerStore = DataStoreService:GetDataStore("ServerPlayerStore")
local serverPlayerDataCache = {}

local serverPlayerDataTemplate = {
	serverDataVersion = 0,
	oldestCompatibleVersion = 0,
}

local serverPlayerDataTypeLayout = {
	serverDataVersion = "number",
	oldestCompatibleVersion = "number",
}

-- Query Client Player Data.
-- Gets the client data of a player from the cache, retrieving it from the Datastore if necessary.
---@param player Player the player to get the data for
---@return table data the client data of the player
local function queryClientPlayerData(player)
	if clientPlayerDataCache[player.UserId] then
		return clientPlayerDataCache[player.UserId]
	end

	local clientPlayerData = clientPlayerStore:GetAsync(player.UserId)

	if not clientPlayerData or not clientPlayerData["clientDataVersion"] then
		clientPlayerData = Utilities.deepCopy(clientPlayerDataTemplate)
		clientPlayerStore:SetAsync(player.UserId, clientPlayerData)
	end

	print(HttpService:JSONEncode(clientPlayerData))

	if clientPlayerData["clientDataVersion"] > clientPlayerDataTemplate["clientDataVersion"] then
		WatchdogService.Trigger(player, "QueryPlayerClientData.DataVersionTooHigh") -- Dunno how this could ever happen, but just in case
		return
	end

	if clientPlayerData["clientDataVersion"] < clientPlayerDataTemplate["clientDataVersion"] then
		if clientPlayerData["clientDataVersion"] < clientPlayerDataTemplate.oldestCompatibleVersion then
			WatchdogService.Trigger(player, "QueryPlayerClientData.DataVersionTooOld")
		end
		local newClientPlayerData = Utilities.deepCopy(clientPlayerDataTemplate)
		for k, v in pairs(clientPlayerData) do
			if k == "clientDataVersion" or k == "oldestCompatibleVersion" then
				continue
			end
			newClientPlayerData[k] = v
		end
	end

	clientPlayerDataCache[player.UserId] = clientPlayerData
	return clientPlayerData
end

-- Query Server Player Data.
-- Gets the server data of a player from the cache, retrieving it from the Datastore if necessary.
-- Under no circumstances should this data ever be directly exposed to a player.
-- If you need to expose this data to a player, you should use the client data store instead.
---@param player Player the player to get the data for
---@return table data the client data of the player
local function queryServerPlayerData(player)
	if serverPlayerDataCache[player.UserId] then
		return serverPlayerDataCache[player.UserId]
	end

	local serverPlayerData = serverPlayerStore:GetAsync(player.UserId)

	if not serverPlayerData or not serverPlayerData["serverDataVersion"] then
		serverPlayerData = Utilities.deepCopy(serverPlayerDataTemplate)
		serverPlayerStore:SetAsync(player.UserId, serverPlayerData)
	end

	print(HttpService:JSONEncode(serverPlayerData))

	if serverPlayerData["serverDataVersion"] > serverPlayerDataTemplate["serverDataVersion"] then
		WatchdogService.Trigger(player, "QueryPlayerServerData.DataVersionTooHigh") -- Dunno how this could ever happen, but just in case
		return
	end

	if serverPlayerData["serverDataVersion"] < serverPlayerDataTemplate["serverDataVersion"] then
		if serverPlayerData["serverDataVersion"] < serverPlayerDataTemplate.oldestCompatibleVersion then
			WatchdogService.Trigger(player, "QueryPlayerServerData.DataVersionTooOld")
		end
		local newserverPlayerData = Utilities.deepCopy(serverPlayerDataTemplate)
		for k, v in pairs(serverPlayerData) do
			if k == "serverDataVersion" or k == "oldestCompatibleVersion" then
				continue
			end
			newserverPlayerData[k] = v
		end
	end

	serverPlayerDataCache[player.UserId] = serverPlayerData
	return serverPlayerData
end

-- Set Client Player Data.
-- Totally overwrites the client data of a player in the cache, and the Datastore.
-- Will verify type integrity of the data before updating.
-- Using this function is a very bad idea. Ensure you know what you're doing before using it.
---@param player Player the player to update for
---@param data table the data to update with
---@return boolean success bool indicating whether the update was successful
local function setClientPlayerData(player, data)
	for k, v in pairs(data) do
		--verify this key exists in the template
		if not clientPlayerDataTemplate[k] then
			WatchdogService.Trigger(player, "SetPlayerClientData.InternalViolationInvalidKey")
			return false
		end
		--verify type integrity of new data
		if type(v) ~= clientPlayerDataTypeLayout[k] then
			WatchdogService.Trigger(player, "SetPlayerClientData.InternalViolationInvalidType")
			return false
		end
	end

	clientPlayerStore:SetAsync(player.UserId, data)
	clientPlayerDataCache[player.UserId] = data
	return true
end

-- Set Server Player Data.
-- Totally overwrites the server data of a player in the cache, and the Datastore.
-- Will verify type integrity of the data before updating.
-- Using this function is a very bad idea. Ensure you know what you're doing before using it.
---@param player Player the player to update for
---@param data table the data to update with
---@return boolean success bool indicating whether the update was successful
local function setServerPlayerData(player, data)
	for k, v in pairs(data) do
		--verify this key exists in the template
		if not serverPlayerDataTemplate[k] then
			WatchdogService.Trigger(player, "SetPlayerServerData.InternalViolationInvalidKey")
			return false
		end
		--verify type integrity of new data
		if type(v) ~= serverPlayerDataTypeLayout[k] then
			WatchdogService.Trigger(player, "SetPlayerServerData.InternalViolationInvalidType")
			return false
		end
	end

	serverPlayerStore:SetAsync(player.UserId, data)
	serverPlayerDataCache[player.UserId] = data
	return true
end

-- Update Client Player Data.
-- Updates the client data of a player in the cache, and the Datastore.
-- Will verify type integrity of the data before updating.
---@param player Player the player to update for
---@param delta table the data to update with
---@return boolean success bool indicating whether the update was successful
local function updateClientPlayerData(player, delta)
	local clientPlayerData = queryClientPlayerData(player)
	if not clientPlayerData then
		return false
	end

	-- create the full package out of the delta
	local fullPackage = Utilities.deepCopy(clientPlayerData)
	for k, v in pairs(delta) do
		fullPackage[k] = v
	end

	return setClientPlayerData(player, fullPackage)
end

-- Update Server Player Data
-- Updates the server data of a player in the cache, and the Datastore.
-- Will verify type integrity of the data before updating.
---@param player Player the player to update for
---@param delta table the data to update with
---@return boolean success bool indicating whether the update was successful
local function updateServerPlayerData(player, delta)
	local serverPlayerData = queryServerPlayerData(player)
	if not serverPlayerData then
		return false
	end

	-- create the full package out of the delta
	local fullPackage = Utilities.deepCopy(serverPlayerData)
	for k, v in pairs(delta) do
		fullPackage[k] = v
	end

	return setServerPlayerData(player, fullPackage)
end

ReplicatedStorage.DataStore:WaitForChild("QueryPlayerData").OnServerInvoke = queryClientPlayerData

DataStoreManager.queryClientPlayerData = queryClientPlayerData
DataStoreManager.queryServerPlayerData = queryServerPlayerData
DataStoreManager.updateClientPlayerData = updateClientPlayerData
DataStoreManager.updateServerPlayerData = updateServerPlayerData
DataStoreManager.setClientPlayerData = setClientPlayerData
DataStoreManager.setServerPlayerData = setServerPlayerData

return DataStoreManager
