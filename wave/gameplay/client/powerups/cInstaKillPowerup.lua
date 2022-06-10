InstaKillPowerup = class()

function InstaKillPowerup:__init()
    self.type = PowerupTypesEnum.InstaKill
end

function InstaKillPowerup:GetActiveId()
    return self.active_id
end

-- Activates a powerup 
function InstaKillPowerup:Activate(args)

    local duration = shGameplayConfig.PowerupData[self.type].duration

    self.active_id = args.id

    LocalPlayer:GetPlayer():SetWeaponDamageModifier(1000)

    GamePlayUI:AddPowerup({
        type = self.type,
        duration = duration
    })

    Citizen.CreateThread(function()
        Citizen.Wait(1000 * duration)
        PowerupManager:EndPowerup({type = self.type, id = args.id})
    end)

end

-- Ends a powerup if it is an ongoing effect
function InstaKillPowerup:End(args)
    
    LocalPlayer:GetPlayer():SetWeaponDamageModifier(1)
    
    GamePlayUI:ModifyPowerup({
        type = self.type,
        charges = 0
    })
    
end