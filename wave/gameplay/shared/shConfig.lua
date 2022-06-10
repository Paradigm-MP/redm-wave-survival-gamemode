shGameplayConfig = class()

-- Must use class because it uses data from another class on init
function shGameplayConfig:__init()

    self.Points = -- Point values for beating up zombies
    {
        Kill = 74,
        RoundBonus = 200
    }

    self.WeaponData = 
    {
        [WeaponEnum.ThrowingKnife] =            {cost = 34, ammo = 1, can_spawn = true, box_chance = 1},
        [WeaponEnum.PistolMauser] =             {cost = 300, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.PistolSemiauto] =           {cost = 300, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.PistolVolcanic] =           {cost = 250, ammo = 50, can_spawn = true, box_chance = 1},
        [WeaponEnum.RepeaterCarbine] =          {cost = 500, ammo = 80, can_spawn = true, box_chance = 1},
        [WeaponEnum.RepeaterHenry] =            {cost = 500, ammo = 40, can_spawn = true, box_chance = 1},
        [WeaponEnum.RifleVarmint] =             {cost = 350, ammo = 80, can_spawn = true, box_chance = 1},
        [WeaponEnum.RepeaterWinchester] =       {cost = 550, ammo = 80, can_spawn = true, box_chance = 1},
        [WeaponEnum.RevolverCattleman] =        {cost = 400, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.RevolverDoubleAction] =     {cost = 600, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.RevolverLemat] =            {cost = 400, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.RevolverSchofield] =        {cost = 450, ammo = 60, can_spawn = true, box_chance = 1},
        [WeaponEnum.RifleBoltaction] =          {cost = 900, ammo = 35, can_spawn = true, box_chance = 1},
        [WeaponEnum.SniperRifleCarcano] =       {cost = 750, ammo = 35, can_spawn = true, box_chance = 1},
        [WeaponEnum.SniperRifleRollingBlock] =  {cost = 950, ammo = 30, can_spawn = true, box_chance = 1},
        [WeaponEnum.RifleSpringField] =         {cost = 550, ammo = 26, can_spawn = true, box_chance = 1},
        [WeaponEnum.ShotgunDoublebarrel] =      {cost = 500, ammo = 32, can_spawn = true, box_chance = 1},
        [WeaponEnum.ShotgunPump] =              {cost = 650, ammo = 35, can_spawn = true, box_chance = 1},
        [WeaponEnum.ShotgunRepeating] =         {cost = 750, ammo = 45, can_spawn = true, box_chance = 1},
        [WeaponEnum.ShotgunSawedoff] =          {cost = 600, ammo = 30, can_spawn = true, box_chance = 1},
        [WeaponEnum.ShotgunSemiauto] =          {cost = 950, ammo = 45, can_spawn = true, box_chance = 1},
        [WeaponEnum.Molotov] =                  {cost = 150, ammo = 1, can_spawn = true, box_chance = 1},
        [WeaponEnum.BrokenSword] =              {cost = 0, ammo = 1, can_spawn = false, box_chance = 1},
        [WeaponEnum.FishingRod] =               {cost = 0, ammo = 1, can_spawn = false, box_chance = 1},
        [WeaponEnum.Hatchet] =                  {cost = 0, ammo = 1, can_spawn = false, box_chance = 1},
        [WeaponEnum.Cleaver] =                  {cost = 0, ammo = 1, can_spawn = false, box_chance = 1},
        [WeaponEnum.Tomahawk] =                 {cost = 0, ammo = 10, can_spawn = false, box_chance = 1},
        [WeaponEnum.Machete] =                  {cost = 0, ammo = 1, can_spawn = false, box_chance = 1},
        [WeaponEnum.Bow] =                      {cost = 0, ammo = 20, can_spawn = false, box_chance = 1},
        [WeaponEnum.Dynamite] =                 {cost = 0, ammo = 6, can_spawn = false, box_chance = 1}
    }

    self.PowerupData = 
    {
        [PowerupTypesEnum.InstaKill] =          {chance = 20, activationType = "all", duration = 30},
        [PowerupTypesEnum.DoubleMoney] =        {chance = 20, activationType = "all", duration = 45},
        [PowerupTypesEnum.MaxAmmo] =            {chance = 20, activationType = "all"},
        [PowerupTypesEnum.LightningStrike] =    {chance = 10, activationType = "single", duration = 60, maxCharges = 5},
        [PowerupTypesEnum.FullHeal] =           {chance = 15, activationType = "all"},
        [PowerupTypesEnum.TimeSlow] =           {chance = 10, activationType = "all", duration = 15},
        [PowerupTypesEnum.Teleport] =           {chance = 10, activationType = "single", duration = 90, maxCharges = 7}
    }

    self.PowerupPickupTime = 60 -- Powerups last for this long on the ground before disappearing
    self.PowerupSpawnChance = 1.15 -- Chance for a powerup to spawn on actor killed, 0-1

    -- Armor data
    self.ArmorData = 
    {
        [0] = {resistance = 1.0, cost = 0},
        [1] = {resistance = 0.8, cost = 10 * 100},
        [2] = {resistance = 0.6, cost = 15 * 100},
        [3] = {resistance = 0.4, cost = 20 * 100},
        [4] = {resistance = 0.2, cost = 25 * 100},
        [5] = {resistance = 0.1, cost = 30 * 100}, -- Greatest resistance
    }

    self.ArmorModel = "P_CS_ARTHURHAT01X"
    self.ArmorMax = 5
end

shGameplayConfig = shGameplayConfig()