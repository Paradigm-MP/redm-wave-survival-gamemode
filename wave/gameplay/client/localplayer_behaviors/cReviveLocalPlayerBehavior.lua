ReviveLocalPlayerBehavior = class()
ReviveLocalPlayerBehavior.name = "ReviveLocalPlayerBehavior"

function ReviveLocalPlayerBehavior:__init()

    self.downed_players = {}
    self.can_revive = true -- Delay on reviving
    self.is_reviving = false -- If the localplayer is reviving someone

    self:CheckIfRevivingOtherPlayer()

    Network:Subscribe("game/sync/start", function(args) self:StartGame(args) end)
    Network:Subscribe("game/sync/end", function() self:EndGame() end)

    Events:Subscribe("LocalPlayerSpawn", function(args) self:LocalPlayerSpawn(args) end)
    Events:Subscribe("PlayerDied", function(args) self:PlayerDied(args) end)
    Events:Subscribe("PlayerDowned", function(args) self:PlayerDowned(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)

    Network:Subscribe("gameplay/PlayerRevived", function(args) self:PlayerRevived(args) end)
end

function ReviveLocalPlayerBehavior:PlayerQuit(args)
    self:RemoveDownedPlayer(args.player:GetUniqueId())
end

function ReviveLocalPlayerBehavior:LocalPlayerSpawn()
    self.last_health = LocalPlayer:GetPed():GetHealth()
end

function ReviveLocalPlayerBehavior:StartGame(args)
    -- TODO: add downed players for players who start spectating and someone is
    -- already downed
    self:ResetDownedPlayers()
end

function ReviveLocalPlayerBehavior:EndGame()
    self:ResetDownedPlayers()
end

function ReviveLocalPlayerBehavior:ResetDownedPlayers()
    for id, data in pairs(self.downed_players) do
        self:RemoveDownedPlayer(id)
    end

    self.downed_players = {}
end

function ReviveLocalPlayerBehavior:CheckIfRevivingOtherPlayer()

    local can_revive = self.can_revive -- can add more checks to this like taking damage

    -- if they are down or not alive, hide all prompts
    if LocalPlayer:GetPlayer():GetValue("Downed") or not LocalPlayer:GetPlayer():GetValue("Alive") then
        for id, data in pairs(self.downed_players) do
            data.prompt:SetVisible(false)
        end
    elseif not can_revive then
        for id, data in pairs(self.downed_players) do
            data.prompt:SetEnabled(false)
        end
    else
        -- If they can revive, then enable the prompts
        local reviving_a_player = false
        for id, data in pairs(self.downed_players) do
            data.prompt:SetVisible(true)
            data.prompt:SetEnabled(true)

            if not data.player or not data.player:GetValue("Downed") or not data.player:GetValue("Alive") then
                self:RemoveDownedPlayer(id)
            elseif data.player and data.player:GetPed() and data.player:GetPed():Exists() then
                
                data.screen_icon:UpdateHealth(self:GetHealthPercent(data))

                reviving_a_player = reviving_a_player or data.prompt:IsHoldModeRunning()

                -- Just in case their body moved
                local pos = data.player:GetPed():GetPosition() + vector3(0, 0, 0.5)
                IconManager:UpdatePosition(data.screen_icon.id, pos)
                data.prompt:SetContextPoint(pos)

                if data.prompt:HasHoldModeCompleted() then
                    self:RemoveDownedPlayer(data.player:GetUniqueId())
                    Network:Send("gameplay/sync/revive_player", {id = data.player:GetUniqueId()})
                    self.can_revive = false
                    LocalPlayer:GetPed():ClearTasksImmediately()

                    Citizen.CreateThread(function()
                        Citizen.Wait(1000)
                        self.can_revive = true
                    end)
                end
            end
        end
        
        local old_reviving = self.reviving
        self.reviving = reviving_a_player
        if self.reviving and not old_reviving then
            -- just started reviving someone
            -- use WORLD_HUMAN_CROUCH_INSPECT for a slower transition, but bad for revive
            LocalPlayer:GetPed():StartScenarioInPlace(GetHashKey("MP_LOBBY_WORLD_HUMAN_CROUCH_INSPECT"))
        elseif not self.reviving and old_reviving then
            -- stopped reviving someone
            LocalPlayer:GetPed():ClearTasksImmediately()
        end
    end

    -- IF the localplayer is down, update their health display on the right
    if self.downed_players[LocalPlayer:GetUniqueId()] then
        local data = self.downed_players[LocalPlayer:GetUniqueId()]
        GamePlayUI:UpdatePlayerHealth(self:GetHealthPercent(data))
    end

    Citizen.CreateThread(function()
        Citizen.Wait(150)
        self:CheckIfRevivingOtherPlayer()
    end)

end

function ReviveLocalPlayerBehavior:GetHealthPercent(data)
    return math.ceil(
        (1 - (data.down_timer:GetMilliseconds() / DownedLocalPlayerBehavior.max_down_time))
        * 100)
end

function ReviveLocalPlayerBehavior:PlayerDied(args)
    self:RemoveDownedPlayer(args.id)
end

function ReviveLocalPlayerBehavior:RemoveDownedPlayer(id)
    local data = self.downed_players[id]
    if data then
        data.prompt:Remove()
        IconManager:Remove(data.screen_icon.id)
        self.downed_players[id] = nil
    end
end

function ReviveLocalPlayerBehavior:PlayerDowned(args)
    self:AddDownedPlayer(args.player)
end

function ReviveLocalPlayerBehavior:AddDownedPlayer(player)

    if self.downed_players[player:GetUniqueId()] then return end

    local is_localplayer = LocalPlayer:IsPlayer(player)

    local screen_icon = ScreenIcon({
        type = ScreenIconTypes.Bounded,
        image_type = ScreenIconImageTypes.Help,
        is_localplayer = is_localplayer
    })

    IconManager:Add({
        screen_icon = screen_icon,
        position = player:GetPed():GetPosition(),
        range = is_localplayer and 0 or 100000
    })

    local prompt = Prompt({
        text = "Hold to revive " .. player:GetName(),
        position = player:GetPed():GetPosition() + vector3(0, 0, 0.5),
        size = is_localplayer and 0 or 1.25,
        control = Control.ShopBuy
    })
    prompt:SetHoldMode(10)

    self.downed_players[player:GetUniqueId()] = 
    {
        screen_icon = screen_icon,
        player = player,
        prompt = prompt,
        down_timer = Timer()
    }
end

function ReviveLocalPlayerBehavior:PlayerRevived(args)
    if not GameManager:GetIsGameInProgress() then return end

    local revived_player = cPlayers:GetByUniqueId(args.player_unique_id)
    self:RemoveDownedPlayer(revived_player:GetUniqueId())
end
