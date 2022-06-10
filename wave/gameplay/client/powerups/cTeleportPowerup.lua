TeleportPowerup = class()

function TeleportPowerup:__init()
    self.type = PowerupTypesEnum.Teleport
    self.active = false
    self.control = Control.Cover
    self.cooldown_time = 1
    self.max_range = 50
    self.cooldown = Timer()
    self.active_id = -1

    Network:Subscribe("gameplay/powerups/UseTeleport", 
        function(args) self:UseTeleport(args) end)
    Events:Subscribe("PlayerDowned", function(args) self:PlayerDowned(args) end)
    Events:Subscribe("LocalPlayerDied", function(args) self:LocalPlayerDied(args) end)
end

function TeleportPowerup:GetActiveId()
    return self.active_id
end

function TeleportPowerup:LocalPlayerDied()
    PowerupManager:EndPowerup({type = self.type, id = self.active_id})
end

function TeleportPowerup:PlayerDowned(args)
    if LocalPlayer:IsPlayer(args.player) and self.active then
        PowerupManager:EndPowerup({type = self.type, id = self.active_id})
    end
end

-- Activates a powerup 
function TeleportPowerup:Activate(args)

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
        key = "Q",
        charges = self.charges
    })

    Citizen.CreateThread(function()
        Citizen.Wait(1000 * duration)
        PowerupManager:EndPowerup({type = self.type, id = args.id})
    end)

    KeyPress:Subscribe(self.control)
    self.keypress = Events:Subscribe("KeyUp", function(args) self:KeyUp(args) end)
    
end

function TeleportPowerup:UseTeleport(args)

    local player = cPlayers:GetByUniqueId(args.id)
    Explosion:Create({
        owner = player:GetPed():GetPedId(),
        position = args.position,
        type = ExplosionTypes.EXP_TAG_LIGHTNING_STRIKE,
        damageScale = 0
    })

    Explosion:Create({
        owner = player:GetPed():GetPedId(),
        position = args.old_position,
        type = ExplosionTypes.EXP_TAG_LIGHTNING_STRIKE,
        damageScale = 0
    })

    Marker({
        type = MarkerTypes.Cylinder,
        position = args.position,
        color = Color(255, 0, 255, 150),
        direction = vector3(0, 0, 0),
        rotation = vector3(0, 0, 0),
        scale = vector3(1, 1, 2)
    }):FadeOut()

    Marker({
        type = MarkerTypes.Cylinder,
        position =  vector3(args.old_position.x, args.old_position.y, args.old_position.z) - vector3(0, 0, 1),
        color = Color(255, 0, 255, 150),
        direction = vector3(0, 0, 0),
        rotation = vector3(0, 0, 0),
        scale = vector3(1, 1, 2)
    }):FadeOut()

    -- If the localplayer used this powerup
    if LocalPlayer:IsPlayer(player) then
        LocalPlayer:SetPosition(args.position)
        self.charges = self.charges - 1
        GamePlayUI:ModifyPowerup({
            type = self.type,
            charges = self.charges
        })
        
        if self.charges == 0 then
            PowerupManager:EndPowerup({type = self.type, id = self.active_id})
        end
    end

end

function TeleportPowerup:KeyUp(args)
    if not self.active then return end

    -- Also a 3 second cooldown between uses
    if args.key == self.control and self.cooldown:GetSeconds() > self.cooldown_time then
        -- fire lightning at location
        local local_pos = LocalPlayer:GetPosition()
        local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * self.max_range)
        if ray.hit and Vector3Math:Distance(ray.position, local_pos) > 3 then

            local rays = 
            {
                Physics:Raycast(ray.position + vector3(0.25, 0, 15), ray.position + vector3(0.25, 0, 0) - vector3(0, 0, 30)),
                Physics:Raycast(ray.position + vector3(-0.25, 0, 15), ray.position + vector3(-0.25, 0, 0) - vector3(0, 0, 30)),
                Physics:Raycast(ray.position + vector3(0, 0.25, 15), ray.position + vector3(0, 0.25, 0) - vector3(0, 0, 30)),
                Physics:Raycast(ray.position + vector3(0, -0.25, 15), ray.position + vector3(0, -0.25, 0) - vector3(0, 0, 30))
            }

            local min_z = GetHeightmapBottomZForPosition(ray.position.x, ray.position.y)

            local final_ray = nil

            for _, raycast in pairs(rays) do
                if raycast.hit and (final_ray == nil or raycast.position.z > final_ray.position.z) and raycast.position.z > min_z then
                    final_ray = raycast
                end
            end

            if final_ray then
                Network:Send("gameplay/powerups/UseTeleport", {
                    position = {x = final_ray.position.x, y = final_ray.position.y, z = final_ray.position.z},
                    old_position = {x = local_pos.x, y = local_pos.y, z = local_pos.z}
                })
                --LocalPlayer:SetPosition(final_ray.position)
                self.cooldown:Restart()
            end

        end
    end
end

-- Ends a powerup if it is an ongoing effect
function TeleportPowerup:End(args)
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