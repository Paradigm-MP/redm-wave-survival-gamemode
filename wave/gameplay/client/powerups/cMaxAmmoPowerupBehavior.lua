MaxAmmoPowerup = class()

function MaxAmmoPowerup:__init()
    self.type = PowerupTypesEnum.MaxAmmo
end

-- Activates a powerup 
function MaxAmmoPowerup:Activate(args)

    -- IF we're not alive then we don't get any ammo
    if not LocalPlayer:GetPlayer():GetValue("Alive") then return end

    local ped = LocalPlayer:GetPed()

    for weaponEnum, data in pairs(shGameplayConfig.WeaponData) do
        local hash = WeaponEnum:GetWeaponHash(weaponEnum)
        if ped:HasWeapon(hash) then
            -- TODO: account for right/left hand weapons
            ped:GiveWeapon(hash, 999, false)
        end
    end

    -- End powerup
    PowerupManager:EndPowerup({type = self.type})

end

-- Ends a powerup if it is an ongoing effect
function MaxAmmoPowerup:End()
    
end