DoubleMoneyPowerup = class()

function DoubleMoneyPowerup:__init()
    self.type = PowerupTypesEnum.DoubleMoney
end

function DoubleMoneyPowerup:GetActiveId()
    return self.active_id
end

-- Activates a powerup 
function DoubleMoneyPowerup:Activate(args)

    -- IF we're not alive then we don't get to use it
    if not LocalPlayer:GetPlayer():GetValue("Alive") or LocalPlayer:GetPlayer():GetValue("Downed") then return end

    local duration = shGameplayConfig.PowerupData[self.type].duration

    self.active_id = args.id

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
function DoubleMoneyPowerup:End(args)
    
    GamePlayUI:ModifyPowerup({
        type = self.type,
        charges = 0
    })

end