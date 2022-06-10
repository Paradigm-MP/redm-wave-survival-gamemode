ArmorPickup = class(Pickup)

--[[
    Creates a new weapon pickup area ingame.

    args (in table):
        position: vector3 of position
]]
function ArmorPickup:__init(args)

    self.cost = shGameplayConfig.ArmorData[1].cost
    self.position = args.position

    self.object = Object({
        model = shGameplayConfig.ArmorModel,
        position = args.position + vector3(0, 0, 0.15),
        isNetwork = false,
        kinematic = true,
        callback = function(obj)
            obj:ToggleCollision(false)
        end
    })

    self.screen_icon = ScreenIcon({
        type = ScreenIconTypes.Unbounded,
        image_type = ScreenIconImageTypes.Armor
    })

    IconManager:Add({
        screen_icon = self.screen_icon,
        position = self.position - vector3(0, 0, 0.5),
        range = 8
    })

    
    self:InitializePickup({
        position = self.position,
        object = self.object,
        light_color = Color(200, 200, 200, 50),
        size = 1.5
    })

    self.control = Control.ShopBuy
    self.timer = Timer()

    self.prompt = Prompt({
        text = "Upgrade Armor for $" .. string.format("%.2f", tonumber(self.cost / 100)),
        position = self.position,
        size = self.size,
        control = self.control
    })

    self.prompt:SetVisible(true)

    KeyPress:Subscribe(self.control)
    self.keypress = Events:Subscribe("KeyUp", function(args) self:KeyPress(args) end)
    self.secondtick = Events:Subscribe("SecondTick", function() self:SecondTick() end)

    self.netval = Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)
end

function ArmorPickup:PlayerNetworkValueChanged(args)
    if not LocalPlayer:IsPlayer(args.player) then return end
    
    if args.name == "Armor" then
        if self.prompt then self.prompt:Remove() end
        self.prompt = nil

        if args.val < shGameplayConfig.ArmorMax then
            self.cost = shGameplayConfig.ArmorData[args.val + 1].cost
        end

        local str = "Upgrade Armor for $" .. string.format("%.2f", tonumber(self.cost / 100))

        if args.val == shGameplayConfig.ArmorMax then
            str = "Armor Fully Upgraded"
        end

        self.prompt = Prompt({
            text = str,
            position = self.position,
            size = self.size,
            control = self.control
        })
        

    end
end

function ArmorPickup:SecondTick()
    if LocalPlayer:GetPlayer():GetValue("Armor") == nil or not self.prompt then return end
    self.prompt:SetEnabled(
        GameManager:GetPoints() >= self.cost 
        and LocalPlayer:GetPlayer():GetValue("Armor") < shGameplayConfig.ArmorMax)
end

function ArmorPickup:KeyPress(args)
    if args.key == self.control 
    and Vector3Math:Distance(LocalPlayer:GetPosition(), self.position) < self.size
    and LocalPlayer:GetPlayer():GetValue("Armor") >= 0 and LocalPlayer:GetPlayer():GetValue("Armor") < 5
    and GameManager:GetPoints() >= self.cost
    and self.timer:GetSeconds() > 1 then
        Network:Send("gameplay/armor/buy_armor")
        self.timer:Restart()
    end
end

function ArmorPickup:Remove()
    self:RemovePickup()
    IconManager:Remove(self.screen_icon.id)
    self.object:Destroy()
    self.prompt:Remove()
    KeyPress:Unsubscribe(self.control)
    self.secondtick:Unsubscribe()
    self.keypress:Unsubscribe()
    self.netval:Unsubscribe()
end
