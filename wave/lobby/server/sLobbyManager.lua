LobbyManager = class()

local LobbyManagerMapCounter = 0
local function GenerateMapId()
    LobbyManagerMapCounter = LobbyManagerMapCounter + 1
    return LobbyManagerMapCounter
end

-- Handles the lobby/queue/map menu stuff
function LobbyManager:__init()

    -- Must list all map names here
    self.file_names = {
        "valentine.json", 
        "annesburg.json", 
        "strawberry.json", 
        "rhodes.json", 
        "stdenisdocks.json", 
        "emeraldranch.json", 
        "stdenisexports.json", 
        "vanhorn.json", 
        "armadillo.json", 
        "fortmercer.json"}

    self.queue = {}
    self.map_data = {}
    self.countdown = 
    {
        max = 20, -- Countdown from when someone readies up to when the game starts
        current = 0,
        active = false
    }

    self.current_map = {}

    self:LoadMapData()
    self:SetupQueue()
    self:SyncMapData()
    self:FullQueueSync()

    -- Set server info
    SetGameType("Wave Survival")
    SetMapName("Various Custom Maps")

    Network:Subscribe("lobby/queue/sync/join", function(args) self:PlayerJoinQueue(args) end)
    Network:Subscribe("lobby/queue/sync/leave", function(args) self:PlayerLeaveQueue(args) end)
    Network:Subscribe("lobby/queue/sync/ready", function(args) self:PlayerReadyQueue(args) end)
    Network:Subscribe("lobby/queue/sync/joinexistinggame", function(args) self:PlayerJoinExistingGame(args) end)
    Network:Subscribe("lobby/maps/sync/ready", function(args) self:PlayerUIReady(args) end)

    Events:Subscribe("PlayerJoin", function(args) self:PlayerJoin(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
    Events:Subscribe("lobby/playerstats/init", function(args) self:PlayerStatsInit(args) end)

    -- ####################################### TEMP
    if IsTest then
        Events:Subscribe('ChatCommand', function(args) self:ChatCommand(args) end)
    end

end

function LobbyManager:ChatCommand(args)
    if args.text == '/val' then
        for id, player in pairs(sPlayers:GetPlayers()) do
            self:PlayerJoinQueue({
                mapname = 'Valentine',
                player = player,
                difficulty = 'easy'
            })
        end
        
        for id, player in pairs(sPlayers:GetPlayers()) do
            self:PlayerReadyQueue({
                player = player
            })
        end

        self:StartGame()
    end
end

function LobbyManager:PlayerStatsInit(args)
    local sync_info = self:GetPlayerBasicSyncInfo(args.player)
    sync_info.action = "update"
    Network:Send("lobby/players/sync/single", -1, sync_info)
end

function LobbyManager:PlayerJoinExistingGame(args)
    GameManager:PlayerJoinExisting(args.player)
end

function LobbyManager:PlayerUIReady(args)
    self:SyncMapData(args.player)
    self:FullQueueSync(args.player)
    self:SyncPlayerData(args.player)
    self:SyncCountdown(args.player)
    self:QueueGameSync(args.player)

    local sync_info = self:GetPlayerBasicSyncInfo(args.player)
    sync_info.action = "add"
    Network:Send("lobby/players/sync/single", -1, sync_info)

    SteamAvatars:PlayerJoined({player = args.player})
    LobbyShopManager:PlayerReady(args.player)
end

function LobbyManager:AvatarLoaded(id)
    local player = sPlayers:GetByUniqueId(id)
    assert(player ~= nil, "AvatarLoaded failed, could not find a valid player")

    local sync_info = self:GetPlayerBasicSyncInfo(player)
    sync_info.action = "update"
    Network:Send("lobby/players/sync/single", -1, sync_info)
end

function LobbyManager:PlayerJoin(args)
    Chat:Broadcast({
        text = args.player:GetName() .. " joined.",
        use_name = true,
        style = "italic",
        color = Colors.Gray
    })
end

function LobbyManager:GetPlayerBasicSyncInfo(p)
    return {
        id = p:GetUniqueId(),
        steamid = p:GetSteamId(),
        name = p:GetName(),
        avatar = SteamAvatars:GetBySteamId(p:GetSteamId()),
        level = p:GetValue("Level")
    }
end

function LobbyManager:SyncPlayerData(player)
    local data = {}
    local this_player_unique_id = player:GetUniqueId()
    
    for player_unique_id, p in pairs(sPlayers:GetPlayers()) do
        data[player_unique_id] = self:GetPlayerBasicSyncInfo(p)

        if player_unique_id == this_player_unique_id then
            data[player_unique_id].is_me = true
        end
    end
    Network:Send("lobby/players/sync/full", player:GetId(), data)
end

-- When a player clicks the "READY" button to ready up (or unready) for a map
function LobbyManager:PlayerReadyQueue(args)
    local mq

    -- Check to see if they're queueing for a map
    for mapname_, data in pairs(self.queue) do
        for difficulty_, mapqueue in pairs(data) do
            -- If this queue has the player
            if mapqueue:HasPlayer(args.player) then
                mq = mapqueue
            end
        end
    end

    -- If we found their mapqueue, flip their READY status
    if mq then
        mq:SetPlayerReady(args.player, not mq:GetPlayerReady(args.player))
        mq:Sync()
        self:CheckCountdown()
    end

end

-- Called when the game ends
function LobbyManager:GameEnd()
    self.current_map = {}
    self:QueueGameSync()
end

-- Syncs the game status to a player (or everyone if not specified). 
-- Shows "GAME IN PROGRESS" screen if a game is running
function LobbyManager:QueueGameSync(player)
    Network:Send("lobby/queue/sync/game", player ~= nil and player:GetId() or -1, self.current_map)
    -- TODO: update this so data.start is false once game ends
end

-- Countdown hit 0 or everyone is ready, so start the game
function LobbyManager:StartGame()
    self.countdown.active = false
    self:SyncCountdown()

    local players, most_players = self:GetReadyPlayers()
    -- determine map and difficulty based on ready players

    local most_maps = {} -- Most ready players on a map (multiple if tied)

    -- Find the maps with most ready players and put them in most_maps
    for mapname, data in pairs(self.queue) do
        for difficulty, mapqueue in pairs(data) do
            if mapqueue:GetNumPlayersReady() == most_players then
                table.insert(most_maps, {mapname = mapname, difficulty = difficulty})
            end
        end
    end

    -- Randomly choose map from those with the largest amounts of ready players
    local chosen_map = most_maps[math.random(#most_maps)]

    self.current_map = chosen_map
    self.current_map.start = true

    GameManager:StartGame({
        map = chosen_map,
        map_data = self.map_data[chosen_map.mapname],
        players = players
    })

    self:ClearQueues()
    self:FullQueueSync()
    self:QueueGameSync()
end

function LobbyManager:GetReadyPlayers()
    local players = {}
    local most = 0
    -- Check to see if they're queueing for a map
    for mapname, data in pairs(self.queue) do
        for difficulty, mapqueue in pairs(data) do
            local ready_players = mapqueue:GetReadyPlayers()
            for id, player in pairs(ready_players) do
                players[id] = player
            end
            most = math.max(count_table(ready_players), most)
        end
    end
    return players, most
end

function LobbyManager:GetNumPlayersReady()
    return count_table(self:GetReadyPlayers())
end

-- Syncs the countdown
function LobbyManager:SyncCountdown(player)
    Network:Send("lobby/queue/sync/countdown", player ~= nil and player:GetId() or -1, self.countdown)
end

-- Ticks the countdown down to 0
function LobbyManager:CountdownTick()
    Citizen.SetTimeout(1000, function()
        if self.countdown.active then
            self.countdown.current = self.countdown.current - 1

            if self.countdown.current == 0 then
                self.countdown.active = false
                self:StartGame()
            else
                self:CountdownTick()
            end
        end
    end)
end

-- Check if anyone is ready and if we should start or stop the countdown
function LobbyManager:CheckCountdown()
    local ready = self:GetNumPlayersReady()
    local num_queued = self:GetNumPlayersQueued()

    -- If everyone who is queued is ready, then start the game
    if ready == num_queued and ready > 0 then
        self:StartGame()
        return
    end

    if self.countdown.active then
        -- if the countdown is running and no one is ready, stop it
        if ready == 0 then
            self.countdown.active = false
            self:SyncCountdown()
        end
    else
        -- If at least one player is ready, start the countdown
        if ready > 0 and not self.countdown.active then
            self.countdown.current = self.countdown.max
            self.countdown.active = true
            self:CountdownTick()
            self:SyncCountdown()
        end
    end

end

-- Gets the number of players who are queued for a map (including ready)
function LobbyManager:GetNumPlayersQueued()
    local cnt = 0
    -- Check to see if they're queueing for a map
    for mapname_, data in pairs(self.queue) do
        for difficulty_, mapqueue in pairs(data) do
            cnt = cnt + mapqueue:GetNumPlayers()
        end
    end

    return cnt
end

-- When someone leaves the server, remove them from the queue if they're in one
function LobbyManager:PlayerQuit(args)
    self:PlayerLeaveQueue(args)
    Network:Send("lobby/players/sync/single", -1, {
        id = args.player:GetUniqueId(),
        action = "remove"
    })
    
    Chat:Broadcast({
        text = args.player:GetName() .. " left.",
        use_name = true,
        style = "italic",
        color = Colors.Gray
    })
end

-- When a player presses the "LEAVE" button for a map or quits the game
function LobbyManager:PlayerLeaveQueue(args)
    local mq

    -- Check to see if they're already queueing for a map
    for mapname_, data in pairs(self.queue) do
        for difficulty_, mapqueue in pairs(data) do
            -- If this queue has the player, remove them
            if mapqueue:HasPlayer(args.player) then
                mapqueue:RemovePlayer(args.player)
                mq = mapqueue
            end
        end
    end

    -- If we found someone and removed them, sync it
    if mq then
        mq:Sync()
        self:CheckCountdown()
    end
end

-- When a 
function LobbyManager:PlayerJoinQueue(args)
    -- Check validity of sent data
    if not args.mapname or not args.difficulty then return end
    if not self.queue[args.mapname] or not self.queue[args.mapname][args.difficulty] then return end

    -- Check to see if they're already queueing for a map
    for mapname, data in pairs(self.queue) do
        for difficulty, mapqueue in pairs(data) do
            -- If this queue has the player and it's not the one they just clicked on, remove them
            if mapqueue:HasPlayer(args.player) and (mapname ~= args.mapname or difficulty ~= args.difficulty) then
                mapqueue:RemovePlayer(args.player)
                mapqueue:Sync()
            end
        end
    end

    local mapqueue = self.queue[args.mapname][args.difficulty]
    -- Now add the player
    mapqueue:AddPlayer(args.player)
    -- And sync to all players
    mapqueue:Sync()
    self:CheckCountdown()
end

-- Syncs all map data to a player, or all players if none specified
function LobbyManager:SyncMapData(player)
    Network:Send("lobby/map/sync/full", player ~= nil and player:GetId() or -1, self.map_data)
end

-- Load all map data
function LobbyManager:LoadMapData()

    for _, file in pairs(self.file_names) do
        local data = JSONUtils:LoadJSON("lobby/server/maps/" .. file)
        if data.enabled == true then
            data["id"] = GenerateMapId() -- Assign each map a unique id 
            self.map_data[data.name] = data
        end
    end

end

function LobbyManager:GetMapData(map_name)
    return self.map_data[map_name]
end

-- Sets up the queue per map per difficulty
function LobbyManager:SetupQueue()

    for mapname, data in pairs(self.map_data) do
        self.queue[mapname] = {}

        for difficulty in pairs(data.difficulties) do
            self.queue[mapname][difficulty] = MapQueue(mapname, difficulty)
        end
    end

end

-- Clears all queues (on game start)
function LobbyManager:ClearQueues()
    for name, queue_data in pairs(self.queue) do
        for difficulty, mapqueue in pairs(self.queue[name]) do
            mapqueue:Clear()
        end
    end
end

--[[
    Syncs all queues to a player, or to all players if none specified
]]
function LobbyManager:FullQueueSync(player)
    local data = {}
    for name, queue_data in pairs(self.queue) do
        data[name] = {}
        for difficulty, mapqueue in pairs(self.queue[name]) do
            data[name][difficulty] = mapqueue:GetSyncData()
        end
    end

    Network:Send("lobby/queue/sync/full", player ~= nil and player:GetId() or -1, data)
end

LobbyManager = LobbyManager()