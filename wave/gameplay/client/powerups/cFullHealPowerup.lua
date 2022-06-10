FullHealPowerup = class()

function FullHealPowerup:__init()
    self.type = PowerupTypesEnum.FullHeal
end

-- Activates a powerup 
function FullHealPowerup:Activate(args)

    -- IF we're not alive then we don't get any ammo
    if not LocalPlayer:GetPlayer():GetValue("Alive") then return end

    LocalPlayer:SetHealth(LocalPlayer.base_health)
    
    -- End powerup
    PowerupManager:EndPowerup({type = self.type})

end

-- Ends a powerup if it is an ongoing effect
function FullHealPowerup:End()
    
end