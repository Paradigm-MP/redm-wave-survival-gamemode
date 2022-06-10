PowerupInstance = class()

local powerup_id = 0

local function GetPowerupId()
    powerup_id = powerup_id + 1
    return powerup_id
end

--[[
    Creates a new Powerup instance in the game world.

    args (in table):
        position (vector3): the position of the powerup
        type (PowerupTypesEnum): the type of powerup
]]
function PowerupInstance:__init(args)
    self.position = args.position
    self.type = args.type

    self.id = GetPowerupId()

    self.spawned = false -- If this has been spawned in the game world yet
    self.picked_up = false -- If this has been picked up by a player yet

    self:Spawn()
end

function PowerupInstance:GetId()
    return self.id
end

function PowerupInstance:Spawn()
    if self.spawned then return end
    Network:Broadcast("gameplay/powerups/spawn", {
        id = self.id,
        position = {x = self.position.x, y = self.position.y, z = self.position.z},
        type = self.type
    })
    self.spawned = true

    Citizen.CreateThread(function()
        Citizen.Wait(1000 * shGameplayConfig.PowerupPickupTime)
        -- IF not one pick it up in time, remove it
        if not self.picked_up then
            self:Remove()
        end
    end)
end

function PowerupInstance:Remove()
    self.picked_up = true
    -- Remove powerup from game world
    Network:Broadcast("gameplay/powerups/remove", {id = self.id})
    PowerupManager:Remove(self.id)
end

function PowerupInstance:Pickup(args)
    if self.picked_up then return end

    -- when a player picks up the powerup and gets its effects
    self.picked_up = true

    self:Remove()

    -- Now trigger its effects on the player(s)
    local powerupData = shGameplayConfig.PowerupData[self.type]

    -- Whether the powerup affects everyone or just the person who got it
    local target = powerupData.activationType == "all" and GameManager:GetPlayerIds() or args.player
    
    Network:Send("gameplay/powerups/activate", target, {type = self.type, id = self:GetId()})

    args.type = self.type
    args.id = self:GetId()

    -- Activate serverside behavior, if any
    PowerupManager:ActivateServersideBehavior(args)

    -- End it manually from the server just in case the clients are messing with
    -- it
    -- Does not account for a restarted powerup (use ID in that case), but
    -- should not matter as powerups are rare
    if powerupData.duration ~= nil then
        Citizen.CreateThread(function()
            local player_id = args.player:GetUniqueId()
            Citizen.Wait(1000 * powerupData.duration)
            Network:Send("gameplay/powerups/end", target, {type = self.type, id = self:GetId()})
            args.player = sPlayers:GetByUniqueId(player_id)
            PowerupManager:DeactivateServersideBehavior(args)
        end)
    end
end
