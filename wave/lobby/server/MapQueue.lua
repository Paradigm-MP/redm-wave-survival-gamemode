MapQueue = class()

-- Container class for keeping track of queued players per map
function MapQueue:__init(name, difficulty)
    self.name = name
    self.difficulty = difficulty

    self.players = {}
end

function MapQueue:GetReadyPlayers()
    local players = {}
    for id, data in pairs(self.players) do
        if self:GetPlayerReady(data.player) then
            players[id] = data.player
        end
    end
    return players
end

function MapQueue:GetNumPlayersReady()
    return count_table(self:GetReadyPlayers())
end

function MapQueue:GetPlayerReady(player)
    return self.players[player:GetUniqueId()] ~= nil and self.players[player:GetUniqueId()].ready or nil
end

function MapQueue:SetPlayerReady(player, ready)
    if self.players[player:GetUniqueId()] then
        self.players[player:GetUniqueId()].ready = ready
    end
end

function MapQueue:HasPlayer(player)
    return self.players[player:GetUniqueId()] ~= nil
end

function MapQueue:AddPlayer(player)
    self.players[player:GetUniqueId()] = {player = player, ready = false}
end

function MapQueue:RemovePlayer(player)
    self.players[player:GetUniqueId()] = nil
end

function MapQueue:GetNumPlayers()
    local count = 0
    for k,v in pairs(self.players) do
        count = count + 1
    end
    return count
end

-- Remove all players
function MapQueue:Clear()
    self.players = {}
end

-- Data data to sync to clients to update their queues
function MapQueue:GetSyncData()
    local data = {}

    -- Least amount of data possible per sync
    for id, d in pairs(self.players) do
        data[id] = {id = id, ready = d.ready}
    end

    return data
end

--[[
    Syncs the MapQueue to a player, or everyone if not specified.
]]
function MapQueue:Sync(player)
    Network:Send("lobby/queue/sync/single", player ~= nil and player:GetId() or -1, 
        {name = self.name, difficulty = self.difficulty, data = self:GetSyncData()})
end