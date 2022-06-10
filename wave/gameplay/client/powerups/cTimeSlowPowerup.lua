TimeSlowPowerup = class()

function TimeSlowPowerup:__init()
    self.type = PowerupTypesEnum.TimeSlow

    World:SetTimeScale(1)
end

function TimeSlowPowerup:GetActiveId()
    return self.active_id
end

-- Activates a powerup 
function TimeSlowPowerup:Activate(args)

    -- IF we're not alive then we don't get slowed
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

    World:SetTimeScale(0.3)

end

-- Ends a powerup if it is an ongoing effect
function TimeSlowPowerup:End()
    World:SetTimeScale(1)

    GamePlayUI:ModifyPowerup({
        type = self.type,
        charges = 0
    })

end