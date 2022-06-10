PowerupManager = class()

function PowerupManager:__init()

    self.active_powerups = {} -- List of currently active powerup enums.
    -- can only have one of each type of powerup active at a time
    self.spawned_powerups = {} -- List of all spawned powerups in the game world
    self.powerup_behaviors = {} -- Map of powerup enums to behavior class singletons

    self:InitializePowerupBehaviors()

    Network:Subscribe("gameplay/powerups/spawn", function(args) self:SpawnPowerup(args) end)
    Network:Subscribe("gameplay/powerups/activate", function(args) self:ActivatePowerup(args) end)
    Network:Subscribe("gameplay/powerups/remove", function(args) self:RemovePowerup(args) end)
    Network:Subscribe("gameplay/powerups/end", function(args) self:EndPowerup(args) end)
    
    Network:Subscribe("game/sync/start", function(args) self:StartGame(args) end)
    Network:Subscribe("game/sync/end", function() self:EndGame() end)
end

function PowerupManager:StartGame()
    self:RemoveAllPowerups()
end

function PowerupManager:EndGame()
    self:RemoveAllPowerups()
end

function PowerupManager:RemoveAllPowerups()
    for type, _ in pairs(self.active_powerups) do
        self.powerup_behaviors[type]:End({force = true})
    end

    self.active_powerups = {}

    for id, powerup in pairs(self.spawned_powerups) do
        powerup:Remove()
    end

    self.spawned_powerups = {}
end

-- Ends a currently active powerup (like lightning powers)
function PowerupManager:EndPowerup(args)
    if self.active_powerups[args.type] then
        if args.id and args.id ~= self.powerup_behaviors[args.type]:GetActiveId() then return end
        if self.powerup_behaviors[args.type]:End(args) == -1 then return end
        self.active_powerups[args.type] = false
    end
end

-- Removes a powerup from the game world
function PowerupManager:RemovePowerup(args)
    if self.spawned_powerups[args.id] then
        self.spawned_powerups[args.id]:Remove()
        self.spawned_powerups[args.id] = nil
    end
end

-- Spawns a powerup in the game world
function PowerupManager:SpawnPowerup(args)
    if self.spawned_powerups[args.id] then return end

    self.spawned_powerups[args.id] = PowerupPickup({
        id = args.id,
        powerupEnum = args.type,
        position = args.position
    })
end

function PowerupManager:ActivatePowerup(args)
    if self.powerup_behaviors[args.type] then
        if self.active_powerups[args.type] then
            self.powerup_behaviors[args.type]:End()
        end

        GamePlayUI:ActivatePowerup(PowerupTypesEnum:GetDescription(args.type))

        self.powerup_behaviors[args.type]:Activate(args)
        self.active_powerups[args.type] = true
    end
end

function PowerupManager:InitializePowerupBehaviors()
    self.powerup_behaviors[PowerupTypesEnum.MaxAmmo] = MaxAmmoPowerup()
    self.powerup_behaviors[PowerupTypesEnum.TimeSlow] = TimeSlowPowerup()
    self.powerup_behaviors[PowerupTypesEnum.FullHeal] = FullHealPowerup()
    self.powerup_behaviors[PowerupTypesEnum.DoubleMoney] = DoubleMoneyPowerup()
    self.powerup_behaviors[PowerupTypesEnum.LightningStrike] = LightningStrikePowerup()
    self.powerup_behaviors[PowerupTypesEnum.Teleport] = TeleportPowerup()
    self.powerup_behaviors[PowerupTypesEnum.InstaKill] = InstaKillPowerup()
end

PowerupManager = PowerupManager()