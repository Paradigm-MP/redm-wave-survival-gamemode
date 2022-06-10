GameManager = class()

function GameManager:__init()
    -- boolean whether a game is currently in progress or not
    getter_setter(self, "is_game_in_progress") -- declares GameManager:GetIsGameInProgress() and GameManager:SetIsGameInProgress() for self.game_in_progress
    GameManager:SetIsGameInProgress(false)

    self.points = 0
    self.round = 1

    -- Preload all player models
    RequestModel(GetHashKey("Player_Zero"))
    RequestModel(GetHashKey("mp_female"))
    RequestModel(GetHashKey("mp_male"))
    RequestModel(GetHashKey("Player_Three"))

    Imap:LoadValentine()

    self.objects = {}
    self.pickups = {}

    Events:Subscribe("LocalPlayerDied", function(args) self:LocalPlayerDied(args) end)
    Events:Subscribe("LocalPlayerSpawn", function(args) self:LocalPlayerSpawn(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
    Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)

    Network:Subscribe("game/sync/start", function(args) self:StartGame(args) end)
    Network:Subscribe("game/sync/end", function() self:EndGame() end)
    Network:Subscribe("game/sync/update_round", function(args) self:SyncNewRound(args) end)
    Network:Subscribe("game/sync/get_weapon", function(args) self:GetWeapon(args) end)
    Network:Subscribe("gameplay/sync/respawn", function() self:Respawn() end)
end

function GameManager:PlayerNetworkValueChanged(args)
    -- Sync game money
    if LocalPlayer:IsPlayer(args.player) and args.name == "GameMoney" then
        self:SyncPoints({points = args.val})
    end
end

function GameManager:GetWeapon(args)
    if not args.weapon then return end

    local hash = WeaponEnum:GetWeaponHash(args.weapon)
    if not hash then return end

    -- If they have the weapon, remove and add a new one to reset durability
    if LocalPlayer:GetPed():HasWeapon(hash) then
        args.ammo = args.ammo + LocalPlayer:GetPed():GetTotalAmmoInWeapon(hash)
        LocalPlayer:GetPed():RemoveWeapon(hash)
    end

    LocalPlayer:GetPed():GiveWeapon(hash, args.ammo, true)
    GamePlayUI:GetUI():CallEvent('gameplayui/purchase/sfx')
end

function GameManager:SyncPoints(args)
    self.points = args.points
    GamePlayUI:UpdatePoints()
end

function GameManager:SyncNewRound(args)
    if not self:GetIsGameInProgress() then return end

    self:RefreshNametags()

    self.round = args.round
    self.wave_type = args.wave_type
    self.survive_until_time = args.survive_until_time

    GameManager:EnforceBossWeaponDamagesIfNecessary()

    GamePlayUI:UpdateRound(true)

    Events:Fire("NewRound", {
        round_number = self.round,
        wave_type = self.wave_type
    })
end

function GameManager:GetWaveType()
    return self.wave_type
end

function GameManager:GetSurviveUntilTime()
    return self.survive_until_time
end

function GameManager:EnforceBossWeaponDamagesIfNecessary()
    --print("Wave Type: ", GameManager:GetWaveType())
    if GameManager:GetWaveType() ~= WaveTypeEnum.Boss then return end

    Citizen.CreateThreadNow(function()
        local round = self.round

        while self.round == round do
            local equipped_weapon_enum = LocalPlayer:GetEquippedWeaponEnum()
            local boss_damage_multiplier = EnemyWeapons:GetBossDamageMultiplierForWeapon(equipped_weapon_enum)
            if boss_damage_multiplier then
                --print("Applying Boss Damage Multiplier")
                LocalPlayer:GetPlayer():SetWeaponDamageModifier(boss_damage_multiplier)
            end

            Wait(800)
        end
        
        if GameManager:GetIsGameInProgress() and self:GetWaveType() ~= WaveTypeEnum.Boss then
            --print("Reset weapon damage modifier after boss round")
            LocalPlayer:GetPlayer():SetWeaponDamageModifier(1.0)
        end
    end)
end

-- Called when the game ends
function GameManager:EndGame()
    if not self:GetIsGameInProgress() then return end

    Citizen.CreateThread(function()
        for actor_unique_id, actor in pairs(ActorManager.actors) do
            if actor:LocalPlayerHasControl() then
                --table.insert(ped_ids_to_delete, actor:GetPedId())
                actor:GetPed():SoftRemove()
                DeleteEntity(actor:GetPedId())
                print("Soft & hard deleted ped")
            else
                print("localplayer does not have control of actor")
            end
        end
    
        self:SetIsGameInProgress(false)
    
        if SpectateMode:GetIsSpectating() then
            SpectateMode:StopSpectating({respawn = false})
        end
    
        LocalPlayer:GetPed():RemoveAllWeapons()
    
        for _, pickup in pairs(self.pickups) do
            pickup:Remove()
        end
    
        for _, object in pairs(self.objects) do
            object:Destroy()
        end
    
        self.armor_pickup:Remove()
        self.armor_pickup = nil

        self.pickups = {}
        self.objects = {}
    
        GamePlayUI:GameEnd() -- Let GamePlayUI handle the UI
    
        Events:Fire("GameEnd")
    end)
end

function GameManager:GetPoints()
    return self.points
end

function GameManager:GetCurrentRound()
    return self.round
end

function GameManager:RefreshNametags()
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        for id, player in pairs(cPlayers:GetPlayers()) do
            if not LocalPlayer:IsPlayer(player) then
                CreateMpGamerTag(player:GetPlayerId(), player:GetName(), false, false, "")
            end
        end
    end)
end


-- Called by the server when a player joins a game (or a game just started and they were ready)
function GameManager:StartGame(args)
    -- Hide ui
    UI:SetCursor(false)
    UI:SetFocus(false)

    BlackScreen:Show()
    LobbyManager:GetUI():Hide()

    if SpectateMode:GetIsSpectating() then
        SpectateMode:StopSpectating({respawn = false})
    end

    local should_spectate = args.spectate[LocalPlayer:GetUniqueId()]

    if not should_spectate then
        Chat:Debug("Not Spectating on StartGame")
        NetworkSetInSpectatorMode(0, 0) -- disables spectate mode
    end

    -- Store data
    self.map = 
    {
        name = args.mapname,
        difficulty = args.difficulty,
        pickups = args.pickups
    }
    self.map_data = LobbyManager:GetMapData()[args.mapname]
    self.round = args.round
    self.wave_type = args.wave_type
    self.survive_until_time = args.survive_until_time

    GameManager:EnforceBossWeaponDamagesIfNecessary()

    World:SetTime(self.map_data.time.hour, self.map_data.time.minute, 0)
    World:SetTimestepEnabled(self.map_data.timestepEnabled)
    World:SetWeather(self.map_data.weather)

    LocalPlayer:GetPed():RemoveAllWeapons()

    self:SpawnMapObjects()

    LocalPlayer:GetPlayer():Freeze(true)
    self:RefreshNametags()

    Filter:Clear()

    if IsTest then
        if self.bounds_marker then self.bounds_marker:Remove() end
        local center = vector3(
            self.map_data.gameArea.center.x, 
            self.map_data.gameArea.center.y, 
            self.map_data.gameArea.center.z)

        self.bounds_marker = Marker({
            type = MarkerTypes.Cylinder,
            position = center,
            direction = vector3(0,0,0),
            rotation = vector3(0,0,0),
            scale = vector3(self.map_data.gameArea.radius * 2, self.map_data.gameArea.radius * 2, 100),
            color = Color(255, 0, 0, 10)
        })
    end

    if self.map_data.filter then
        Filter:Apply({
            name = self.map_data.filter.name,
            amount = self.map_data.filter.amount
        })
    end

    if LocalPlayer.behaviors.DownedLocalPlayerBehavior then
        LocalPlayer.behaviors.DownedLocalPlayerBehavior:SetDowned(false)
    end

    SetLocalPlayerCanUsePickupsWithThisModel(GetHashKey(LocalPlayer:GetPlayer():GetValue("Model")), false)

    if not should_spectate then
        GameManager:Respawn(function()
            Citizen.CreateThread(function()
                Citizen.Wait(500)
                GamePlayUI:GameStart()
                self:SpawnMapWeaponPickups()
                self:SpawnMapArmor()
                Camera:Reset()
                --[[Chat:Print("<i>[#7c6c59]Howdy, partner! The goal of this gamemode is to survive for as long " ..
                "as possible. You get money when you kill enemies. You can spend your money to " .. 
                "buy guns at <b>gun spawns that are hidden around the map</b>. If your teammate goes down, "..
                "you can revive them by standing over them and holding E. "..
                "<br><br>Good luck, and " .. 
                "please let us know on Discord if you have any questions!</i>")]]
                BlackScreen:Hide(2000)
                Citizen.Wait(1000)
                GamePlayUI:UpdateRound()
            end)
        end)
    else
        -- Spectate Scenario #3: Enable spectate if joining an existing game
        SpectateMode:Enable(2)
        GamePlayUI:GameStart()
        self:SpawnMapWeaponPickups()
        self:SpawnMapArmor()
        Camera:Reset()
        BlackScreen:Hide(2000)
        GamePlayUI:UpdateRound()
    end

    self:SetIsGameInProgress(true)
    SpawnManager:NewGame(self.map_data)
end

function GameManager:GetRandomPlayerSpawnPoint()
    return self.map_data.playerSpawnPoints[math.random(#self.map_data.playerSpawnPoints)].pos
end

function GameManager:GetRoundNumber()
    return self.round
end

function GameManager:Respawn(cb)
    local model_data_split = split(LocalPlayer:GetPlayer():GetValue("Model"), "|")
    local model = model_data_split[1]
    local outfit = tonumber(model_data_split[2])
    if outfit == nil then outfit = tonumber(split(model_data_split[2], ",")[1]) end
    LocalPlayer:Spawn({
        pos = self:GetRandomPlayerSpawnPoint(),
        model = model,
        callback = function()

            if cb then cb() end
            -- override health
            -- TODO: adjust with difficulty
            LocalPlayer:SetHealth(LocalPlayer.base_health)
            LocalPlayer:GetPed():SetOutfitPreset(outfit)

            -- Continuously set outfit in case they have not loaded the model
            Citizen.CreateThread(function()
                local timer = Timer()
                while timer:GetSeconds() < 20 do
                    LocalPlayer:GetPed():SetOutfitPreset(outfit)
                    Citizen.Wait(1000)
                end
            end)

            for _, weapon_data in pairs(self.map_data.defaultWeapons) do
                local hash = WeaponEnum:GetWeaponHash(weapon_data.type)
                LocalPlayer:GetPed():GiveWeapon(hash, weapon_data.ammo, true)
            end
        end
    })

end

function GameManager:SpawnMapArmor()

    if not self.map_data.armorSpawnPoint then
        print("[WARNING] No armor spawnpoint found")
        return
    end
    
    local pos_table = self.map_data.armorSpawnPoint.pos
    local pos = vector3(pos_table.x, pos_table.y, pos_table.z)

    self.armor_pickup = ArmorPickup({position = pos})

end

function GameManager:SpawnMapWeaponPickups()
    -- spawn all weapon pickups from self.map_data

    for _, pickup_data in pairs(self.map.pickups) do
        local pos = vector3(pickup_data.pos.x, pickup_data.pos.y, pickup_data.pos.z);
        table.insert(self.pickups, WeaponPickup({
            weaponEnum = pickup_data.type,
            position = pos,
            cost = pickup_data.cost
        }))

        IconManager:Add({
            screen_icon = ScreenIcon({
                type = ScreenIconTypes.Unbounded,
                image_type = ScreenIconImageTypes.Weapon
            }),
            position = pos - vector3(0, 0, 0.5),
            range = 10
        })

    end
end

function GameManager:SpawnMapObjects()
    -- spawn all objects from self.map_data
    for _, object_data in pairs(self.map_data.objectSpawnPoints) do
        table.insert(self.objects, Object({
            model = object_data.model,
            rotation = vector3(object_data.rot.x, object_data.rot.y, object_data.rot.z),
            position = vector3(object_data.pos.x, object_data.pos.y, object_data.pos.z),
            kinematic = true,
            isNetwork = false,
            callback = function(object)
                self.objects[object:GetEntity()] = object
                if self.map_data.invisibleObjects[object_data.model] then
                    object:SetAlpha(0)
                end
            end
        }))
    end
end

function GameManager:LocalPlayerDied(args)

end

function GameManager:LocalPlayerSpawn(args)
    -- TODO: fix friendlies sometimes attacking players
    -- dont do this so we can detect the damage and then mitigate / clear that peds tasks
    -- DISABLE THIS
    --LocalPlayer:SetIsInvincibleFromActorGroup(ActorGroupEnum.FriendlyGroup, true)
end

function GameManager:GetAlivePlayers()
    local t = {}

    for id, player in pairs(cPlayers:GetPlayers()) do
        if player:GetValue("Alive") and not player:GetValue("Spectate") and not player:GetValue("Downed") then
            t[id] = player
        end
    end

    return t
end

function GameManager:PlayerQuit(args)

end

GameManager = GameManager()