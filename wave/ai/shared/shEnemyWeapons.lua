EnemyWeapons = class()

function EnemyWeapons:__init()
    self.pistols = {
        WeaponEnum.RevolverDoubleAction,
        WeaponEnum.PistolVolcanic,
        WeaponEnum.PistolSemiauto,
        WeaponEnum.PistolMauser,
        WeaponEnum.RevolverCattleman,
        WeaponEnum.RevolverDoubleAction,
        WeaponEnum.RevolverSchofield
    }

    self.repeater_rifles = {
        WeaponEnum.RepeaterCarbine,
        WeaponEnum.RepeaterWinchester,
        WeaponEnum.RifleVarmint,
        WeaponEnum.RepeaterHenry
    }

    self.shotguns = {
        WeaponEnum.ShotgunDoublebarrel,
        WeaponEnum.ShotgunPump,    
        WeaponEnum.ShotgunRepeating,
        WeaponEnum.ShotgunSawedoff,
        WeaponEnum.ShotgunSemiauto
    }

    self.rifles = {
        WeaponEnum.RifleSpringField,
        WeaponEnum.RifleBoltaction
    }

    self.snipers = {
        WeaponEnum.SniperRifleCarcano,
        WeaponEnum.SniperRifleRollingBlock
    }

    self.weapon_classes = {
        ["Pistols"] = self.pistols,
        ["Repeaters"] = self.repeater_rifles,
        ["Shotguns"] = self.shotguns,
        ["Rifles"] = self.rifles,
        ["Snipers"] = self.snipers
    }

    -------
    -------
    -------
    -------
    self.round_1_5_weights = {
        ["Pistols"] = 100,
        ["Repeaters"] = 3,
        ["Shotguns"] = 1,
        ["Rifles"] = 3,
        ["Snipers"] = 1
    }

    self.round_5_10_weights = {
        ["Pistols"] = 65,
        ["Repeaters"] = 20,
        ["Shotguns"] = 5,
        ["Rifles"] = 5,
        ["Snipers"] = 3
    }

    self.round_10_15_weights = {
        ["Pistols"] = 50,
        ["Repeaters"] = 30,
        ["Shotguns"] = 15,
        ["Rifles"] = 10,
        ["Snipers"] = 7
    }

    self.round_15_20_weights = {
        ["Pistols"] = 40,
        ["Repeaters"] = 35,
        ["Shotguns"] = 20,
        ["Rifles"] = 15,
        ["Snipers"] = 10
    }

    self.round_20_25_weights = {
        ["Pistols"] = 35,
        ["Repeaters"] = 35,
        ["Shotguns"] = 25,
        ["Rifles"] = 20,
        ["Snipers"] = 15
    }

    self.round_25_30_weights = {
        ["Pistols"] = 30,
        ["Repeaters"] = 30,
        ["Shotguns"] = 35,
        ["Rifles"] = 15,
        ["Snipers"] = 15
    }
end

function EnemyWeapons:GetRandomWeaponForRound(round_number)
    local weights

    if round_number >= 0 and round_number <= 4 then
        weights = self.round_1_5_weights
    elseif round_number >= 5 and round_number < 10 then
        weights = self.round_5_10_weights
    elseif round_number >= 10 and round_number < 15 then
        weights = self.round_10_15_weights
    elseif round_number >= 15 and round_number < 20 then
        weights = self.round_15_20_weights
    elseif round_number >= 20 and round_number < 25 then
        weights = self.round_20_25_weights
    else
        weights = self.round_25_30_weights
    end

    return random_table_value(self.weapon_classes[EnemyWeapons:GetRandomWeaponClassFromWeights(weights)])
end

function EnemyWeapons:GetRandomWeaponClassFromWeights(weights)
    local sum = 0
    for _,weight in pairs(weights) do
        sum = sum + weight
    end

    local rand = math.random() * sum
    local found
    for item, weight in pairs(weights) do
        rand = rand - weight
        if rand < 0 then
            found = item
            break
        end
    end

    return found
end

function EnemyWeapons:GetBossDamageMultiplierForWeapon(weapon_enum)
    local melee_damage_modifier = 0.05
    local pistol_damage_modifier = 0.05
    local revolver_damage_modifier = 0.08
    local shotgun_damage_modifier = 0.08
    local sniper_damage_modifier = 0.06
    local repeater_damage_modifier = 0.08

    local boss_damage_multipliers = {
        [WeaponEnum.MoonshineJug] =    melee_damage_modifier,
        [WeaponEnum.ElectricLantern] = melee_damage_modifier,
        [WeaponEnum.Torch] =           melee_damage_modifier,
        [WeaponEnum.BrokenSword] =     melee_damage_modifier,
        [WeaponEnum.FishingRod] =      melee_damage_modifier,
        [WeaponEnum.Hatchet] =         melee_damage_modifier,
        [WeaponEnum.Cleaver] =         melee_damage_modifier,
        [WeaponEnum.AncientHatchet] =  melee_damage_modifier,
        [WeaponEnum.VikingHatchet] =   melee_damage_modifier,
        [WeaponEnum.HewingHatchet] =   melee_damage_modifier,
        [WeaponEnum.DoubleBitHatchet] = melee_damage_modifier,
        [WeaponEnum.DoubleBitRustedHatchet] = melee_damage_modifier,
        [WeaponEnum.HunterHatchet] = melee_damage_modifier,
        [WeaponEnum.RustedHunterHatchet] = melee_damage_modifier,
        [WeaponEnum.KnifeJohn] = melee_damage_modifier,
        [WeaponEnum.Knife] = melee_damage_modifier,
        [WeaponEnum.KnifeJawbone] = melee_damage_modifier,
        [WeaponEnum.ThrowingKnife] = 0.10,
        [WeaponEnum.KnifeMiner] = melee_damage_modifier,
        [WeaponEnum.KnifeCivilWar] = melee_damage_modifier,
        [WeaponEnum.KnifeBear] = melee_damage_modifier,
        [WeaponEnum.KnifeVampire] = melee_damage_modifier,
        [WeaponEnum.Machete] = melee_damage_modifier,
        [WeaponEnum.Tomahawk] = 0.10,
        [WeaponEnum.TomahawkAncient] = 0.20,
        [WeaponEnum.PistolMauser] = pistol_damage_modifier,
        [WeaponEnum.PistolSemiauto] = pistol_damage_modifier,
        [WeaponEnum.PistolVolcanic] = pistol_damage_modifier,
        [WeaponEnum.RepeaterCarbine] = repeater_damage_modifier,
        [WeaponEnum.RepeaterHenry] = repeater_damage_modifier,
        [WeaponEnum.RifleVarmint] = repeater_damage_modifier,
        [WeaponEnum.RepeaterWinchester] = repeater_damage_modifier,
        [WeaponEnum.RevolverCattleman] = revolver_damage_modifier,
        [WeaponEnum.RevolverDoubleAction] = revolver_damage_modifier,
        [WeaponEnum.RevolverLemat] = revolver_damage_modifier,
        [WeaponEnum.RevolverSchofield] = revolver_damage_modifier,
        [WeaponEnum.RifleBoltaction] = sniper_damage_modifier,
        [WeaponEnum.SniperRifleCarcano] = sniper_damage_modifier,
        [WeaponEnum.SniperRifleRollingBlock] = sniper_damage_modifier,
        [WeaponEnum.RifleSpringField] = repeater_damage_modifier,
        [WeaponEnum.ShotgunDoublebarrel] = shotgun_damage_modifier,
        [WeaponEnum.ShotgunPump] = shotgun_damage_modifier,
        [WeaponEnum.ShotgunRepeating] = shotgun_damage_modifier,
        [WeaponEnum.ShotgunSawedoff] = shotgun_damage_modifier,
        [WeaponEnum.ShotgunSemiauto] = shotgun_damage_modifier,
        [WeaponEnum.Bow] = 0.10,
        [WeaponEnum.Dynamite] = 0.08,
        [WeaponEnum.Molotov] = 0.05
    }

    if not boss_damage_multipliers[weapon_enum] then
        print("weapon enum not found in EnemyWeapon:GetBossDamageMultiplierForWeapon")
        return tofloat(0.01)
    end

    return tofloat(boss_damage_multipliers[weapon_enum])
end

function EnemyWeapons:GetRandomMeleeWeapon()
    local random_melee_weapon_enum = random_weighted_table_value({
        [WeaponEnum.Knife] = 10,
        [WeaponEnum.KnifeJawbone] = 10,
        [WeaponEnum.KnifeMiner] = 10,
        [WeaponEnum.KnifeCivilWar] = 10,
        [WeaponEnum.KnifeJohn] = 10,
        [WeaponEnum.BrokenSword] = 10
    })

    return random_melee_weapon_enum
end

function EnemyWeapons:GetRandomSingleWeaponType()
    return random_weighted_table_value({
        [WeaponTypeEnum.Sniper] = 6,
        [WeaponTypeEnum.Rifle] = 6,
        [WeaponTypeEnum.Shotgun] = 10,
        [WeaponTypeEnum.Repeater] = 10
    })
end

function EnemyWeapons:GetRandomWeaponFromType(weapon_type_enum)
    local weights = {
        [WeaponTypeEnum.Repeater] = 
            {
                [WeaponEnum.RepeaterCarbine] = 10,
                [WeaponEnum.RepeaterWinchester] = 10,
                [WeaponEnum.RepeaterHenry] = 10
            },
        [WeaponTypeEnum.Rifle] = 
            {
                [WeaponEnum.RifleSpringField] = 8,
                [WeaponEnum.RifleBoltaction] = 10
            },
        [WeaponTypeEnum.Sniper] = 
            {
                [WeaponEnum.SniperRifleCarcano] = 10,
                [WeaponEnum.SniperRifleRollingBlock] = 10
            },
        [WeaponTypeEnum.Shotgun] = 
            {
                [WeaponEnum.ShotgunDoublebarrel] = 10,
                [WeaponEnum.ShotgunPump] = 10,
                [WeaponEnum.ShotgunRepeating] = 10,
                [WeaponEnum.ShotgunSawedoff] = 6,
                [WeaponEnum.ShotgunSemiauto] = 10
            }
    }

    if not weights[weapon_type_enum] then
        print("Error in shEnemyWeapon:GetRandomWeaponFromType - weapon type {", weapon_type_enum, "} not mapped")
    end

    return random_weighted_table_value(weights[weapon_type_enum])
end

EnemyWeapons = EnemyWeapons()