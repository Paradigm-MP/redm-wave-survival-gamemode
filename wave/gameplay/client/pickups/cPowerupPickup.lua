PowerupPickup = class(Pickup)

--[[
    Creates a new powerup pickup area ingame.

    args (in table):
        id: id of the powerup from the server
        powerupEnum: enum of powerup to create
        position: vector3 of position
]]
function PowerupPickup:__init(args)

    self.id = args.id
    self.powerupEnum = args.powerupEnum
    self.position = vector3(args.position.x, args.position.y, args.position.z)

    local model, scale = PowerupTypesEnum:GetPowerupModel(self.powerupEnum)

    self.object = Object({
        model = model,
        position = self.position,
        isNetwork = false,
        kinematic = true,
        callback = function(obj)
            obj:ToggleCollision(false)
            if not self.marker then obj:Destroy() end -- Object was created after someone picked it up
        end
    })

    self.screen_icon = ScreenIcon({
        type = ScreenIconTypes.Unbounded,
        image_type = ScreenIconImageTypes.Powerup
    })

    IconManager:Add({
        screen_icon = self.screen_icon,
        position = self.position,
        range = 50
    })

    self:InitializePickup({
        position = self.position,
        object = self.object,
        light_color = Color(255, 0, 255, 150),
        size = 2
    })

    self.fade_with_distance = false

    self:CheckIfInRange()

end

function PowerupPickup:CheckIfInRange()
    Citizen.CreateThread(function()

        local local_pos = LocalPlayer:GetPosition()
        local dist = Vector3Math:Distance(local_pos, self.position)

        if dist < self.size then
            Network:Send('gameplay/powerups/pickup', {id = self.id})
            self:Remove()
            return
        end

        Citizen.Wait(10)
        self:CheckIfInRange()
    end)
end


function PowerupPickup:Remove()
    self:RemovePickup()
    IconManager:Remove(self.screen_icon.id)
    self.object:Destroy()
end
