PowerupManager = class()

function PowerupManager:__init()
    self.spawned_powerups = {} -- List of all spawned powerups in the game world

    -- Serverside powerup behaviors
    self.powerup_behaviors = 
    {
        [PowerupTypesEnum.FullHeal] = PowerupFullHeal(),
        [PowerupTypesEnum.DoubleMoney] = PowerupDoubleMoney(),
        [PowerupTypesEnum.LightningStrike] = PowerupLightningStrike(),
        [PowerupTypesEnum.Teleport] = PowerupTeleport()
    }

    Network:Subscribe("gameplay/powerups/pickup", function(args) self:PickupPowerup(args) end)
    Events:Subscribe("ActorKilled", function(args) self:ActorKilled(args) end)
end

function PowerupManager:ActorKilled(args)
    math.randomseed(os.time())
    if math.random() < shGameplayConfig.PowerupSpawnChance then
        self:CreatePowerup({
            position = args.actor_position,
            type = self:GetRandomPowerupEnum()
        })
    end
end

function PowerupManager:GetRandomPowerupEnum()
    local total = 0
    for enum, data in pairs(shGameplayConfig.PowerupData) do
        total = total + data.chance
    end

    local chance = math.random(total)

    local running_total = 0
    for enum, data in pairs(shGameplayConfig.PowerupData) do
        running_total = running_total + data.chance
        if chance <= running_total then
            return enum
        end
    end

    print("[WARNING] PowerupManager:GetRandomPowerupEnum failed to get a random powerup enum")
    return 1
end

function PowerupManager:GetBehavior(type)
    return self.powerup_behaviors[type]
end

function PowerupManager:ActivateServersideBehavior(args)
    if self.powerup_behaviors[args.type] then
        self.powerup_behaviors[args.type]:Activate(args)
    end
end

function PowerupManager:DeactivateServersideBehavior(args)
    if self.powerup_behaviors[args.type] then
        self.powerup_behaviors[args.type]:Deactivate(args)
    end
end

function PowerupManager:PickupPowerup(args)
    if not args.player:GetValue("Alive") or args.player:GetValue("Downed") then return end
    if args.id == nil or not self.spawned_powerups[args.id] then return end

    self.spawned_powerups[args.id]:Pickup({player = args.player})
end

-- Removes a powerup from the spawned powerups table. Make sure to call
-- powerup:Remove before this!
function PowerupManager:Remove(id)
    if self.spawned_powerups[id] then
        self.spawned_powerups[id] = nil
    end
end

--[[
    Creates a powerup in the game world. 

    args (in table):
        position (vector3): position of the powerup
        type (PowerupTypesEnum): enum of the type of powerup to spawn
]]
function PowerupManager:CreatePowerup(args)
    local powerup = PowerupInstance(args)
    self.spawned_powerups[powerup:GetId()] = powerup
end

PowerupManager = PowerupManager()