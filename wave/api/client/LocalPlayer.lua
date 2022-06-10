LocalPlayer = immediate_class()
LocalPlayer.base_health = 500

function LocalPlayer:__init()
    getter_setter(self, "name") -- declares LocalPlayer:GetName() and LocalPlayer:SetName() for self.name
    getter_setter(self, "unique_id") -- declares LocalPlayer:GetUniqueId() and LocalPlayer:SetUniqueId() for self.unique_id
    getter_setter(self, "is_spawning") -- declares LocalPlayer:GetIsSpawning() and LocalPlayer:SetIsSpawning() for self.is_spawning

    self.spawned = false
    self.controls_enabled = true

    self.last_recorded_health = 0
    self:MonitorHealthChanges()

    ShutdownLoadingScreen()
    self:RestrictActions()
    self.values = ValueStorage()
    self.values:InitializeValueStorage(self)
end

function LocalPlayer:__postLoad()
    --print("entered LocalPlayer:__postLoad")
    LocalPlayer:ConfigureBehaviors()
end

function LocalPlayer:ConfigureBehaviors()
    self.behaviors = {}

    -- taint damage with encoded localplayer identity
    -- self.behaviors.BulletDetectionLocalPlayerBehavior = BulletDetectionLocalPlayerBehavior()

    self.behaviors.DownedLocalPlayerBehavior = DownedLocalPlayerBehavior() -- handles downing & undowning the LocalPlayer
    self.behaviors.RestrictAreaLocalPlayerBehavior = RestrictAreaLocalPlayerBehavior() -- handles map restriction
    self.behaviors.ReviveLocalPlayerBehavior = ReviveLocalPlayerBehavior() -- handles player reviving
    self.behaviors.ArmorLocalPlayerBehavior = ArmorLocalPlayerBehavior()
    --self.behaviors.ReportEnemyInactivityLocalPlayerBehavior = ReportEnemyInactivityLocalPlayerBehavior() -- handles player reviving
end

function LocalPlayer:MonitorHealthChanges()
    Citizen.CreateThread(function()
        local current_health
        local localplayer_ped_id

        while true do
            Wait(10)
            
            localplayer_ped_id = LocalPlayer:GetPedId()
            current_health = GetEntityHealth(localplayer_ped_id)

            if localplayer_ped_id == 0 then
                print("Error: localplayer_ped_id is zero")
            end
            if self.last_recorded_health ~= current_health then
                local old_health = self.last_recorded_health
                local damage = self.last_recorded_health - current_health -- positive for damaged, negative for healed
                self.last_recorded_health = current_health

                --print("LocalPlayer health changed to: " .. tostring(current_health))

                Events:Fire("LocalPlayerHealthChanged", {
                    old_health = old_heath,
                    new_health = current_health,
                    damage = damage
                })
            end
        end
    end)
end

function LocalPlayer:IsPlayer(player)
    return self:GetUniqueId() == player:GetUniqueId()
end

-- LocalPlayer:GiveWeapon(WeaponEnum.AssaultRifle)
function LocalPlayer:GiveWeapon(weapon_enum)
    local hash = WeaponEnum:GetWeaponHash(weapon_enum)
    --Chat:Print("Hash: " .. tostring(hash))
    GiveWeaponToPed(ped_id, hash, 260, false, true)
end

function LocalPlayer:GetEquippedWeaponEnum()
    local _, localplayer_weapon_hash = GetCurrentPedWeapon(self:GetPedId())
    return WeaponEnum:GetFromWeaponHash(localplayer_weapon_hash)
end

function LocalPlayer:GetEquippedWeapon()
    local has_weapon, localplayer_weapon_hash = GetCurrentPedWeapon(self:GetPedId())
    return has_weapon, WeaponEnum:GetFromWeaponHash(localplayer_weapon_hash)
end

function LocalPlayer:GetCurrentClipAmmo()
    local _, ammo = GetAmmoInClip(self:GetPedId(), WeaponEnum:GetWeaponHash(self:GetEquippedWeaponEnum()))
    return ammo
end

function LocalPlayer:GetCurrentClipAmmoForWeapon(weapon_enum)
    local _, ammo = GetAmmoInClip(self:GetPedId(), WeaponEnum:GetWeaponHash(weapon_enum))
    return ammo
end

--[[
    Restricts players from doing anything except standing still
]]
function LocalPlayer:ToggleControls(enabled)
    self.controls_enabled = enabled

    if not self.controls_enabled then
        DisableAllControlActions(0)
    else
        EnableAllControlActions(0)
    end
end

function LocalPlayer:RestrictActions()
    print("LocalPlayer restricting actions")

    -- disables weapon melee
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1) -- a short delay of 5 ms
            --DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            --DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            --DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            --DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            --DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            --DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            --DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            --DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            --DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
        end
    end)
end

function LocalPlayer:SetHealth(health)
    local ped_id = LocalPlayer:GetPedId()
    local ped_max_health = GetEntityMaxHealth(ped_id)
    --print("ped_max_health: ", ped_max_health)

    -- set new max health if health > max health
    if health > ped_max_health then
        SetEntityMaxHealth(ped_id, health - 100)
        --print("new max health: ", GetEntityMaxHealth(ped_id))
    end

    SetEntityHealth(ped_id, health)
    --print("new health: ", GetEntityHealth(ped_id))
end

function LocalPlayer:GetHealth()
    return GetEntityHealth(LocalPlayer:GetPedId())
end

function LocalPlayer:StopRagdollImmediately()
    SetPedCanRagdoll(LocalPlayer:GetPedId(), false)
    Citizen.CreateThread(function()
        Wait(250)
        SetPedCanRagdoll(LocalPlayer:GetPedId(), true)
    end)
end

function LocalPlayer:SetValue(name, val)
    self.values:SetValue(name, val)
end

function LocalPlayer:GetValue(name)
    return self.values:GetValue(name)
end

function LocalPlayer:IsSpawned()
    return self.spawned
end

--[[
    Spawns the LocalPlayer.

    args: (in table)

    pos - (vector3) the position you want to spawn
    model - (string) the model you want to have

    heading (optional) - (number) the direction you want to be facing
    callback (optional) - (function) function to call after spawning finishes
]]
function LocalPlayer:Spawn(args)
    if self:GetIsSpawning() then
        print("LocalPlayer:Spawn() called but already spawning")
        return
    end

    self:SetIsSpawning(true)

    -- freeze the local player
    self:GetPlayer():Freeze(true)

    Citizen.CreateThread(function()
        self:GetPlayer():SetModel(args.model, function()
            -- preload collisions for the spawnpoint
            RequestCollisionAtCoord(args.pos.x, args.pos.y, args.pos.z)
    
            -- spawn the player
            local ped = self:GetPedId()
    
            self:SetPosition(args.pos)
            -- Respawn the player
            self:NetworkResurrect(args)
    
            ClearPedTasksImmediately(ped)
            ClearPlayerWantedLevel(PlayerId())
    
            local timer = Timer()
    
            while not HasCollisionLoadedAroundEntity(ped) and timer:GetSeconds() < 10 do
                Citizen.Wait(1)
            end
    
            ShutdownLoadingScreen()
    
            -- and unfreeze the player
            self:GetPlayer():Freeze(false)

            --print("LocalPlayer Health: ", GetEntityHealth(LocalPlayer:GetPedId()))
            -- 150 for Player Zero by default

            LocalPlayer:SetActorGroup(ActorGroupEnum.PlayerGroup)

            self:SetIsSpawning(false)
            self.spawned = true
            Events:Fire("LocalPlayerSpawn", {})
    
            if args.callback then
                args.callback()
            end
        end)
    end)
end

function LocalPlayer:Freeze(freeze)
    self:GetPlayer():Freeze(freeze)
end

function LocalPlayer:SetInvisible(invisible)
    --NetworkSetEntityInvisibleToNetwork(LocalPlayer:GetPedId(), invisible)
    local player = LocalPlayer:GetPlayer()
    player:GetPed():SetAlpha(0)
    player:GetPed():ToggleCollision(enabled)
end

--[[
    Resurrects/respawns the LocalPlayer

    args: (in table)
    pos - (vector3) where you want the LocalPlayer to resurrect
    
    heading (optional) - (number) the direction you want the LocalPlayer to face when resurrected

]]
function LocalPlayer:NetworkResurrect(args)
    NetworkResurrectLocalPlayer(args.pos.x, args.pos.y, args.pos.z, args.heading or 0, true, true, false)
    self.ped = Ped({ped = GetPlayerPed(PlayerId())})
end

function LocalPlayer:GetPlayer()
    return cPlayers:GetByUniqueId(self:GetUniqueId())
end

function LocalPlayer:HasPed()
    return DoesEntityExist(self:GetPedId())
end

function LocalPlayer:GetPed()
    return Ped({ped = self:GetPedId()})
end

function LocalPlayer:GetPlayerId()
    return PlayerId()
end

function LocalPlayer:GetPedId()
    return GetPlayerPed(PlayerId())
end

function LocalPlayer:GetEntity()
    return Entity(GetPlayerPed(PlayerId()))
end

function LocalPlayer:GetEntityId()
    return GetPlayerPed(PlayerId())
end

function LocalPlayer:SetActorGroup(actor_group_enum)
    SetPedRelationshipGroupHash(LocalPlayer:GetPedId(), ActorGroupEnum:GetGroupHash(actor_group_enum))
end

function LocalPlayer:GetActorGroupEnum()
    return ActorGroupEnum:GetFromHash(GetPedRelationshipGroupHash(self:GetPedId()))
end

function LocalPlayer:SetIsInvincibleFromActorGroup(actor_group_enum, is_invincible)
    SetEntityCanBeDamagedByRelationshipGroup(LocalPlayer:GetPedId(), not is_invincible, ActorGroupEnum:GetGroupHash(actor_group_enum))
end

function LocalPlayer:SetTotallyInvincible(invincible)
    self.invincible = invincible
    SetEntityInvincible(LocalPlayer:GetPedId(), invincible)
end

function LocalPlayer:GetTotallyInvincible()
    return self.invincible
end

function LocalPlayer:SetPosition(position) -- FiveM vector3
    self:GetPed():SetPosition(position)
end

function LocalPlayer:GetPosition()
    return self:GetPed():GetPosition()
end

-- example: local x, y, z = LocalPlayer:GetPositionXYZ()
function LocalPlayer:GetPositionXYZ()
    return table.unpack(self:GetPosition())
end

function LocalPlayer:TeleportToPlayer(server_player_id)
    --print("server_player_id", server_player_id)
    local target = cPlayers:GetByServerId(server_player_id)

    --print("target: ", target)

    if target and target:GetPed():GetEntity() ~= LocalPlayer:GetPed():GetEntity() then
        local pos = target:GetPosition()
        --print("target pos: ", pos)
        --print("LocalPlayer pos: ", self:GetPosition())
        self:SetPosition(target:GetPosition() + vector3(0, 0, 4))
    end
end

LocalPlayer = LocalPlayer()