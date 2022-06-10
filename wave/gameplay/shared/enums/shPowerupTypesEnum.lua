PowerupTypesEnum = immediate_class(Enum)

function PowerupTypesEnum:__init()
    self:EnumInit()

    self.InstaKill = 1
    self:SetDescription(self.InstaKill, "DeadShot") -- all enemies die in one hit

    self.DoubleMoney = 2
    self:SetDescription(self.DoubleMoney, "Double Money") -- all enemies give double money

    self.MaxAmmo = 3
    self:SetDescription(self.MaxAmmo, "Max Ammo") -- everyone gets max ammo for all their weapons

    self.LightningStrike = 4
    self:SetDescription(self.LightningStrike, "Lightning Strike") -- player can look and create lightning strikes

    self.FullHeal = 5
    self:SetDescription(self.FullHeal, "Full Heal") -- everyone healed to full and downed players are upped

    self.TimeSlow = 6
    self:SetDescription(self.TimeSlow, "Time Slow") -- time is slowed for a bit

    self.Teleport = 7
    self:SetDescription(self.Teleport, "Teleport") -- player can teleport to look location

    self.InvincibleFire = 8
    self:SetDescription(self.InvincibleFire, "Flame Invincibility") -- all players become invincible and are on fire

    self.enum_to_model_map = 
    {
        [self.InstaKill] = {model = "P_AXE01X", scale = 2},
        [self.DoubleMoney] = {model = "P_MONEYSTACK01X", scale = 4},
        [self.MaxAmmo] = {model = "s_lootablepoorcase", scale = 4},
        [self.LightningStrike] = {model = "S_INV_ORLEANDER01CX", scale = 4},
        [self.FullHeal] = {model = "S_INV_MEDICINE01X", scale = 4},
        [self.TimeSlow] = {model = "p_clock06x", scale = 2},
        [self.Teleport] = {model = "p_binoculars01x", scale = 2},
        [self.InvincibleFire] = {model = "p_binoculars01x", scale = 2},
    }
end

function PowerupTypesEnum:GetPowerupModel(type)
    -- TODO: different models for different powerups
    return self.enum_to_model_map[type].model, self.enum_to_model_map[type].scale
end

PowerupTypesEnum = PowerupTypesEnum()