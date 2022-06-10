LightningStrikePowerup = class()

function LightningStrikePowerup:__init()
    self.type = PowerupTypesEnum.LightningStrike
    self.active = false
    self.control = Control.MeleeAttack
    self.cooldown_time = 3
    self.max_range = 100
    self.cooldown = Timer()
    self.active_id = -1

    Network:Subscribe("gameplay/powerups/UseLightningStrike", 
        function(args) self:UseLightningStrike(args) end)
    Events:Subscribe("PlayerDowned", function(args) self:PlayerDowned(args) end)
    Events:Subscribe("LocalPlayerDied", function(args) self:LocalPlayerDied(args) end)
end

function LightningStrikePowerup:GetActiveId()
    return self.active_id
end

function LightningStrikePowerup:LocalPlayerDied()
    PowerupManager:EndPowerup({type = self.type, id = self.active_id})
end

function LightningStrikePowerup:PlayerDowned(args)
    if LocalPlayer:IsPlayer(args.player) and self.active then
        PowerupManager:EndPowerup({type = self.type, id = self.active_id})
    end
end

-- Activates a powerup 
function LightningStrikePowerup:Activate(args)

    if self.active then
        PowerupManager:EndPowerup({type = self.type, id = self.active_id})
    end

    -- IF we're not alive then we don't get to use it
    if not LocalPlayer:GetPlayer():GetValue("Alive") or LocalPlayer:GetPlayer():GetValue("Downed") then return end

    self.charges = shGameplayConfig.PowerupData[self.type].maxCharges

    self.active = true
    self.active_id = args.id
    local duration = shGameplayConfig.PowerupData[self.type].duration

    GamePlayUI:AddPowerup({
        type = self.type,
        duration = duration,
        key = "F",
        charges = self.charges
    })

    Citizen.CreateThread(function()
        Citizen.Wait(1000 * duration)
        PowerupManager:EndPowerup({type = self.type, id = args.id})
    end)

    KeyPress:Subscribe(self.control)
    self.keypress = Events:Subscribe("KeyUp", function(args) self:KeyUp(args) end)
    
end

function LightningStrikePowerup:UseLightningStrike(args)

    local old_weather = World:GetWeather()
    World:SetWeather("RAIN") -- Must make rain to make lightning appear

    Citizen.CreateThread(function()
        Citizen.Wait(10)
        local old_invin = LocalPlayer:GetTotallyInvincible()
        LocalPlayer:SetTotallyInvincible(true)

        -- SetWeatherTypeTransition 0.5f transition time

        local pos = vector3(args.position.x, args.position.y, args.position.z)
        ForceLightningFlashAtCoords(pos.x, pos.y, pos.z + 0.1)

        -- Protect players from lightning damage
        local player = cPlayers:GetByUniqueId(args.id)
        Explosion:Create({
            owner = player:GetPed():GetPedId(),
            position = pos,
            type = ExplosionTypes.EXP_TAG_DYNAMITE_VOLATILE
        })

        -- If the localplayer used this powerup
        if LocalPlayer:IsPlayer(player) then
            self.charges = self.charges - 1
            GamePlayUI:ModifyPowerup({
                type = self.type,
                charges = self.charges
            })
            
            if self.charges == 0 then
                PowerupManager:EndPowerup({type = self.type, id = self.active_id})
            end
        end

        Citizen.Wait(300)
        LocalPlayer:SetTotallyInvincible(old_invin)
        World:SetWeather(old_weather)
    end)

end

function LightningStrikePowerup:KeyUp(args)
    if not self.active then return end

    -- Also a 3 second cooldown between uses
    if args.key == self.control and self.cooldown:GetSeconds() > self.cooldown_time then
        -- fire lightning at location
        local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * self.max_range)
        if ray.hit and Vector3Math:Distance(ray.position, LocalPlayer:GetPosition()) > 3 then
            Network:Send("gameplay/powerups/UseLightningStrike", {
                position = {x = ray.position.x, y = ray.position.y, z = ray.position.z}
            })
        end
        self.cooldown:Restart()
    end
end

-- Ends a powerup if it is an ongoing effect
function LightningStrikePowerup:End(args)
    if not self.active then return -1 end

    self.active = false
    self.charges = 0
    GamePlayUI:ModifyPowerup({
        type = self.type,
        charges = self.charges
    })
    
    KeyPress:Unsubscribe(self.control)
    self.keypress:Unsubscribe()
end