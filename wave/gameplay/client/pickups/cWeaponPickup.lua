WeaponPickup = class(Pickup)

--[[
    Creates a new weapon pickup area ingame.

    args (in table):
        weaponEnum: enum of weapon to create
        cost: cost of weapon
        position: vector3 of position
]]
function WeaponPickup:__init(args)

    self.weaponEnum = args.weaponEnum
    self.cost = args.cost
    self.position = args.position
    self.timer = Timer()

    self.objects = {}

    for k, model_name in pairs(WeaponEnum:GetWeaponModel(self.weaponEnum)) do
        table.insert(self.objects, Object({
            model = model_name,
            position = self.position + vector3(0, 0, 0.15),
            isNetwork = false,
            kinematic = true,
            callback = function(obj)
                if not self.marker then obj:Destroy() end -- Object was created after someone picked it up
            end
        }))
    end

    self:InitializePickup({
        position = self.position,
        objects = self.objects,
        light_color = Color(255, 255, 0, 50),
        size = 1.5
    })

    self.control = Control.ShopBuy

    self.prompt = Prompt({
        text = "Buy " .. WeaponEnum:GetDescription(self.weaponEnum) .. " for $" .. string.format("%.2f", tonumber(self.cost / 100)),
        position = self.position,
        size = self.size,
        control = self.control
    })

    KeyPress:Subscribe(self.control)
    self.keypress = Events:Subscribe("KeyUp", function(args) self:KeyPress(args) end)
    self.secondtick = Events:Subscribe("SecondTick", function() self:SecondTick() end)

end

function WeaponPickup:SecondTick()
    self.prompt:SetEnabled(GameManager:GetPoints() >= self.cost)
end

function WeaponPickup:KeyPress(args)
    local ped = LocalPlayer:GetPed()
    local weapon_hash = WeaponEnum:GetWeaponHash(self.weaponEnum)

    if args.key == self.control 
    and Vector3Math:Distance(LocalPlayer:GetPosition(), self.position) < self.size
    and (not ped:HasWeapon(weapon_hash) or ped:GetTotalAmmoInWeapon(weapon_hash) < ped:GetWeaponMaxAmmo(weapon_hash))
    and self.timer:GetSeconds() > 1 -- 1 second delay between buying weapon
    and GameManager:GetPoints() >= self.cost then
        Network:Send("game/pickup/buy_weapon", {
            weapon = self.weaponEnum
        })
        self.timer:Restart()
    end
end

function WeaponPickup:Remove()
    self:RemovePickup()
    self.prompt:Remove()
    for k,v in pairs(self.objects) do v:Destroy() end
    KeyPress:Unsubscribe(self.control)
    self.secondtick:Unsubscribe()
    self.keypress:Unsubscribe()
end
