PlayerStatsManager = class()

function PlayerStatsManager:__init()

    Events:Subscribe("gamedatabase/ready", function() self:GameDatabaseReady() end)
    Events:Subscribe("ClientReady", function(args) self:ClientReady(args) end)
    Events:Subscribe("MinuteTick", function() self:MinuteTick() end)
    Network:Subscribe("gameplay/PlayerDowned", function(args) self:PlayerDowned(args) end)
    Events:Subscribe("ActorKilled", function(args) self:ActorKilled(args) end)
    Events:Subscribe("GameEnd", function() self:GameEnd() end)
end

function PlayerStatsManager:GetDateNow()
    return os.date("%Y-%m-%d-%H-%M-%S")
end

-- Called when a game ends
function PlayerStatsManager:GameEnd()
    for _, player in pairs(GameManager:GetPlayers()) do
        if player:GetValue("DBInitialized") then
            local gamestats = player:GetValue("GameStats")
            gamestats.games_played = gamestats.games_played + 1
            player:SetValue("GameStats", gamestats)
            self:SavePlayerToDB(player)
        end
    end
end

function PlayerStatsManager:PlayerDowned(args)
    if args.player:GetValue("DBInitialized") then
        local gamestats = args.player:GetValue("GameStats")
        gamestats.deaths = gamestats.deaths + 1 -- deaths = downed
        args.player:SetValue("GameStats", gamestats)
        self:SavePlayerToDB(args.player)
    end
end

function PlayerStatsManager:ActorKilled(args)
    if args.killer_type == "Player" and args.killer and args.killer:GetValue("DBInitialized") then
        local gamestats = args.killer:GetValue("GameStats")
        gamestats.kills = gamestats.kills + 1
        args.killer:SetValue("GameStats", gamestats)
        self:SavePlayerToDB(args.killer)
    end
end



-- Ticks every minute to update player stats
function PlayerStatsManager:MinuteTick()
    self:UpdatePlayerOnlineTimes()
end

function PlayerStatsManager:UpdatePlayerOnlineTimes()
    Citizen.CreateThread(function()
        for id, player in pairs(sPlayers:GetPlayers()) do
            if player:GetValue("DBInitialized") then
                player:SetNetworkValue("TimeOnline", player:GetValue("TimeOnline") + 1)
                self:SavePlayerToDB(player)
                Citizen.Wait(100)
            end
        end
    end)
end

function PlayerStatsManager:GameDatabaseReady()
    -- load stuff
end

-- Called when a client has joined
function PlayerStatsManager:ClientReady(args)
    local query = "SELECT * FROM player_data WHERE unique_id=@uniqueid"
    local params = {["@uniqueid"] = args.player:GetUniqueId()}
    SQL:Fetch(query, params, function(result)
        if result and result[1] then
            self:InitPlayerStats(args.player, result[1])
        else
            self:InitPlayerStats(args.player, {
                unique_id = args.player:GetUniqueId(),
                name = args.player:GetName(),
                model = "Player_Zero",
                time_online = 0,
                kills = 0,
                deaths = 0,
                last_login_ip = args.player:GetIP(),
                level = 1,
                exp = 0,
                games_played = 0,
                last_online = self:GetDateNow()
            })
            self:SavePlayerToDB(args.player)
        end
    end)
end

--[[
    Saves a player to DB with their current level, exp, gamestats, and time online
]]
function PlayerStatsManager:SavePlayerToDB(player)

    local cmd = "INSERT INTO player_data (unique_id, name, model, time_online, kills, deaths, last_login_ip, level, exp, games_played, last_online)"..
        "VALUES(@uniqueid, @name, @model, @timeonline, @kills, @deaths, @lastloginip, @level, @exp, @gamesplayed, @last_online) "..
        "ON DUPLICATE KEY UPDATE name=@name, level=@level, exp=@exp, time_online=@timeonline, last_login_ip=@lastloginip, "..
        "kills=@kills, deaths=@deaths, games_played=@gamesplayed, last_online=@last_online, model=@model"
    local params = 
    {
        ["@uniqueid"] = player:GetUniqueId(),
        ["@name"] = player:GetName(),
        ["@model"] = player:GetValue("Model"),
        ["@timeonline"] = player:GetValue("TimeOnline"),
        ["@kills"] = player:GetValue("GameStats").kills,
        ["@deaths"] = player:GetValue("GameStats").deaths,
        ["@lastloginip"] = player:GetIP(),
        ["@level"] = player:GetValue("Level"),
        ["@gamesplayed"] = player:GetValue("GameStats").games_played,
        ["@exp"] = player:GetValue("Exp"),
        ["@last_online"] = self:GetDateNow(), -- Always save current date
    }

    SQL:Execute(cmd, params, function(rows)
        --
    end)
end

function PlayerStatsManager:InitPlayerStats(player, data)
    player:SetValue("RawStats", data)
    player:SetNetworkValue("Level", data.level)
    player:SetNetworkValue("Exp", data.exp)
    player:SetValue("GameStats", {deaths = data.deaths, kills = data.kills, games_played = data.games_played})
    player:SetNetworkValue("TimeOnline", data.time_online)
    player:SetValue("DBInitialized", true)
    player:SetNetworkValue("Model", LobbyShopManager:HandlePlayerModel(player, data.model))
    player:SetNetworkValue("LastOnline", data.last_online)

    Events:Fire("gameplay/playerstats/init", {player = player})
end

PlayerStatsManager = PlayerStatsManager()