GameManager = class()

function GameManager:__init()
    -- boolean whether a game is currently in progress or not
    getter_setter(self, "is_game_in_progress") -- declares GameManager:GetIsGameInProgress() and GameManager:SetIsGameInProgress() for self.game_in_progress
    GameManager:SetIsGameInProgress(false)

    Events:Subscribe("ChatCommand", function(args)
        if args.text == "/money" then
            args.player:SetNetworkValue("GameMoney", args.player:GetValue("GameMoney") + 1000)
        end
    end)

    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
    Events:Subscribe("PlayerDied", function(args) self:PlayerDied(args) end)
    Events:Subscribe("ActorKilled", function(args) self:ActorKilled(args) end)

    Network:Subscribe("gameplay/PlayerDowned", function(args) self:PlayerDowned(args) end)
    Network:Subscribe("gameplay/sync/revive_player", function(args) self:PlayerRevived(args) end)
    Network:Subscribe("gameplay/armor/buy_armor", function(args) self:PlayerBuyArmor(args) end)
end

function GameManager:PlayerBuyArmor(args)
    if not GameManager:GetIsGameInProgress() then return end
    if not args.player:GetValue("Alive") or args.player:GetValue("Downed") then return end

    local current_armor = args.player:GetValue("Armor")
    if current_armor >= shGameplayConfig.ArmorMax then return end

    local armor_data = shGameplayConfig.ArmorData[current_armor + 1]
    if not armor_data then return end

    if args.player:GetValue("GameMoney") < armor_data.cost then return end

    args.player:SetNetworkValue("Armor", current_armor + 1)
    args.player:SetNetworkValue("GameMoney", args.player:GetValue("GameMoney") - armor_data.cost)
end

function GameManager:PlayerRevived(args)
    local revivee = sPlayers:GetByUniqueId(args.id)
    assert(revivee ~= nil, "GameManager:PlayerRevived failed, could not find a valid player")

    if revivee:GetUniqueId() == args.player:GetUniqueId() then return end
    if not revivee:GetValue("Downed") or not revivee:GetValue("Alive") then return end
    if args.player:GetValue("Downed") or not args.player:GetValue("Alive") then return end

    revivee:SetNetworkValue("Downed", false)

    Network:Broadcast("gameplay/PlayerRevived", {
        player_unique_id = revivee:GetUniqueId(),
        reviver_unique_id = args.player:GetUniqueId()
    })
end

-- Resets game info like round, time elapsed, etc
function GameManager:ResetGameInfo(args)
    self.game_info = 
    {
        round = 1,
        timer = Timer(),
        map = args.map,
        players = args.players,
        map_data = args.map_data
    }
end

function GameManager:GetGameInfo()
    return self.game_info
end

-- Syncs the new round to all players
function GameManager:SyncNewRound()
    Network:Broadcast("game/sync/update_round", {
        round = self.game_info.round,
        wave_type = SpawnManager:GetWaveType(),
        survive_until_time = SpawnManager:GetSurviveUntilTime()
    })
end

function GameManager:PlayerDowned(args)
    Events:Fire("PlayerDowned", args)
    args.player:SetNetworkValue("Downed", true)

    if self:GetIsGameInProgress() then
        self:CheckIfGameShouldEnd()
    end
end

function GameManager:PlayerDied(args)
    args.player:SetNetworkValue("Alive", false)

    if self:GetIsGameInProgress() then
        self:CheckIfGameShouldEnd()
    end
end

function GameManager:PlayerQuit(args)
    if self:GetIsGameInProgress() then
        self.game_info.players[args.player:GetId()] = nil
        self:CheckIfGameShouldEnd()
    end
end

-- Checks if alive players == 0, and if so, game ends
function GameManager:CheckIfGameShouldEnd()
    if count_table(self:GetAlivePlayers()) == 0 then
        self:EndGame()
    end
end

-- Ends a game because everyone either died or left
function GameManager:EndGame()
    Network:Broadcast("game/sync/end")
    GameManager:SetIsGameInProgress(false)
    LobbyManager:GameEnd()

    Events:Fire("GameEnd", {})
    print("GameManager:EndGame")
end

-- Called by LobbyManager when a game starts
function GameManager:StartGame(args)

    self:ResetGameInfo(args)
    GameManager:SetIsGameInProgress(true)

    -- Set values on players
    for id, player in pairs(args.players) do
        GameManager:SetPlayerStartGameValues(player, true, false)
    end

    WeaponPickupManager:RandomizeWeaponPickups()

    self:NewRound(true)

    Network:Send("game/sync/start", self:GetPlayerIds(), self:GetGameSyncInfo())
end

function GameManager:NewRound(is_first_round)
    if not is_first_round then -- not necessary on first round
        self.game_info.round = self.game_info.round + 1
    end
    
    -- generates the next wave
    SpawnManager:NewRound(self.game_info.round, self.game_info.difficulty, count_table(self.game_info.players))

    local time = SpawnManager:GetWaveTime()
    if not time then
        World:SetTime(LobbyManager:GetMapData(self.game_info.map.mapname).time.hour, 0, 0)
        --print("[1]Set time to {", tostring(LobbyManager:GetMapData(self.game_info.map.mapname).time.hour), "}")
    else
        World:SetTime(time, 0, 0)
        --print("[2]Set time to {", time, "}")
    end

    -- Wait a little bit before setting weather, after setting the game time
    Citizen.CreateThreadNow(function()
        local saved_round_number = GameManager:GetRoundNumber()
        Wait(2000)
        if GameManager:GetRoundNumber() == saved_round_number then
            local weather = SpawnManager:GetWaveWeather()
            if not weather then
                World:SetWeather(LobbyManager:GetMapData(self.game_info.map.mapname).weather)
                print("Set weather to {", tostring(LobbyManager:GetMapData(self.game_info.map.mapname).weather), "}")
            else
                World:SetWeather(weather)
                print("Set weather to {", weather, "}")
            end
        end
    end)

    for _, player in pairs(self.game_info.players) do
        if not is_first_round and not player:GetValue("Alive") then
            -- respawn player
            Network:Send("gameplay/sync/respawn", player)
        end
        player:SetNetworkValue("Downed", false)
        player:SetNetworkValue("Alive", true)
        player:SetNetworkValue("Spectate", false)

        if not is_first_round then
            -- Round bonus money
            self:AddMoneyToPlayer(player, shGameplayConfig.Points.RoundBonus)
        end
    end

    if not is_first_round then -- not necessary on first round
        self:SyncNewRound()
    end
end

function GameManager:GetRoundNumber()
    return self.game_info.round
end

function GameManager:GetMoneyModifier()
    local double_pts = PowerupManager:GetBehavior(PowerupTypesEnum.DoubleMoney):IsActive()
    return double_pts and 2 or 1
end

function GameManager:AddMoneyToPlayer(player, amount)
    local old_money = player:GetValue("GameMoney") or 0
    local money_to_add = amount * self:GetMoneyModifier()
    local updated_money = old_money + money_to_add
    player:SetNetworkValue("GameMoney", updated_money)
    LobbyShopManager:PlayerAddIngameMoney(player, money_to_add)
end

function GameManager:GetGameSyncInfo()
    return {
        mapname = self.game_info.map.mapname,
        difficulty = self.game_info.map.difficulty,
        round = self.game_info.round,
        wave_type = SpawnManager:GetWaveType(),
        survive_until_time = SpawnManager:GetSurviveUntilTime(),
        pickups = WeaponPickupManager:GetWeaponPickups(),
        spectate = self:GetSpectatingPlayers()
    }
end

function GameManager:GetSpectatingPlayers()
    local t = {}

    for id, player in pairs(self:GetPlayers()) do
        if player:GetValue("Spectate") then
            t[player:GetUniqueId()] = true
        end
    end
    
    return t
end

-- args.killer not guaranteed
function GameManager:ActorKilled(args)
    if args.killer_type == "Player" and args.killer then
        self:AddMoneyToPlayer(args.killer, shGameplayConfig.Points.Kill)
    end
end

function GameManager:PlayerJoinExisting(player)
    if self.game_info.players[player:GetId()] then return end

    self.game_info.players[player:GetId()] = player
    local should_spectate = self.game_info.timer:GetSeconds() > 15
    GameManager:SetPlayerStartGameValues(player, not should_spectate, should_spectate)
    Network:Send("game/sync/start", player:GetId(), self:GetGameSyncInfo())
end

function GameManager:SetPlayerStartGameValues(player, alive, spectate)
    player:SetNetworkValue("Alive", alive) -- boolean
    player:SetNetworkValue("Downed", false)
    player:SetNetworkValue("Spawned", true)
    player:SetNetworkValue("GameMoney", 0)
    player:SetNetworkValue("Spectate", spectate)
    player:SetNetworkValue("Armor", 0)

    player:SetNetworkValue("InGame", true)
end

-- Gets a table of player ids who are in the game
function GameManager:GetPlayerIds()
    local ids = {}
    for id, player in pairs(self:GetPlayers()) do
        table.insert(ids, player:GetId())
    end
    return ids
end

-- Gets all players in the game (whether alive or dead or not spawned yet)
function GameManager:GetPlayers()
    return self.game_info.players
end

-- Gets all the players who are alive in the game
function GameManager:GetAlivePlayers()
    local players = {}
    for id, player in pairs(self:GetPlayers()) do
        if player:GetValue("Alive") and player:GetValue("Spawned") and not player:GetValue("Downed") then
            players[id] = player
        end
    end
    return players
end

GameManager = GameManager()