SteamAvatars = class()

function SteamAvatars:__init()
    self.avatars = {} -- Table of steam avatars
    self.request_url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=API_KEY&steamids="

    Events:Subscribe("PlayerJoined", function(args) self:PlayerJoined(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
end

-- Gets an avatar by steam id
function SteamAvatars:GetBySteamId(id)
    return self.avatars[id]
end

-- Get and store avatar urls on join
function SteamAvatars:PlayerJoined(args)
    local steam_id = args.player:GetSteamId()
    local id = args.player:GetUniqueId()
    self:GetSteamAvatar(steam_id, function(url)
        self.avatars[steam_id] = url
        LobbyManager:AvatarLoaded(id)
    end)
end

function SteamAvatars:PlayerQuit(args)
    self.avatars[args.player:GetSteamId()] = nil
end

-- A function to get players' steam avatars
function SteamAvatars:GetSteamAvatar(id_hex, callback)
    local id = tonumber(tostring(id_hex), 16)
    if self.avatars[id_hex] then return self.avatars[id_hex] end
    PerformHttpRequest(self.request_url .. tostring(id), function(err, text, headers)
        if not text then
            Citizen.CreateThread(function()
                Citizen.Wait(1000)
                self:GetSteamAvatar(id_hex, callback)
                return
            end)
        end
        local data = text ~= nil and json.decode(text) or nil
        if data and data.response and data.response.players and data.response.players[1] then
            self.avatars[id_hex] = data.response.players[1].avatarmedium
            callback(data.response.players[1].avatarmedium)
        else
            --print("Could not retrieve steam avatar for id: " .. tostring(id_hex))
        end
    end, 'GET', '')
end

SteamAvatars = SteamAvatars()


--[[
Just in case you want more data
{
    "response":
        {"players":
        [
            {
                "steamid":"76561198022561173",
                "communityvisibilitystate":3,
                "profilestate":1,
                "personaname":"Lord Farquaad",
                "lastlogoff":1564043425,
                "profileurl":"https://steamcommunity.com/id/coolman1337/",
                "avatar":"https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/69/69f109df54e4b1e75feeee569f3a754305c02a6b.jpg",
                "avatarmedium":"https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/69/69f109df54e4b1e75feeee569f3a754305c02a6b_medium.jpg",
                "avatarfull":"https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/69/69f109df54e4b1e75feeee569f3a754305c02a6b_full.jpg",
                "personastate":1,
                "primaryclanid":"103582791463380511",
                "timecreated":1268864279,
                "personastateflags":0}]}}

]]