Pickup = class()

local MAX_DIST_MARKER = 60

--[[
    Creates a new weapon pickup area ingame.

    args (in table):
        object: object that was created that should spin
        position: vector3 of position
        light_color: Color of light on the pickup
        size: numer of size
]]
function Pickup:__init(args)
    self:InitializePickup(args)
end

function Pickup:InitializePickup(args)

    self.object = args.object
    self.objects = args.objects or {}
    self.position = args.position
    self.size = args.size
    self.color = args.light_color

    self.light = Light({
        position = args.position,
        color = args.light_color,
        type = LightTypes.Point,
        shadow = false,
        range = self.size,
        intensity = 10
    })

    self.marker = Marker({
        position = args.position - vector3(0, 0, 1),
        color = args.light_color,
        type = MarkerTypes.Cylinder,
        direction = vector3(0, 0, 0),
        rotation = vector3(0, 0, 0),
        scale = vector3(self.size * 1.25, self.size * 1.25, self.size * 0.75)
    })

    self.delta = 0
    self.fade_with_distance = true

    self.render = Events:Subscribe("Render", function() self:Render() end)
    self.pickupsecondtick = Events:Subscribe("SecondTick", function() self:PickupSecondTick() end)
end

function Pickup:PickupSecondTick()
    if not self.fade_with_distance then return end
    local alpha = 1 - math.min(MAX_DIST_MARKER, Vector3Math:Distance(LocalPlayer:GetPosition(), self.position)) / MAX_DIST_MARKER
    self.marker:SetColor(Color(self.color.r, self.color.g, self.color.b, alpha * self.color.a))
end

function Pickup:Render()
    if self.object and self.object:Exists() then
        -- Make it spin
        self.object:SetRotation(self.object:GetRotation() + vector3(0, 0, 1))
        self.object:SetPosition(self.position + vector3(0, 0, math.sin(self.delta) * 0.05))
        self.delta = self.delta + 0.03
    end

    for k, object in pairs(self.objects) do
        -- Make it spin
        object:SetRotation(object:GetRotation() + vector3(0, 0, 1))
        object:SetPosition(self.position + vector3(0, 0, math.sin(self.delta) * 0.05))
        self.delta = self.delta + 0.03
    end
end

function Pickup:RemovePickup()
    if self.render then self.render:Unsubscribe() self.render = nil end
    if self.pickupsecondtick then self.pickupsecondtick:Unsubscribe() self.pickupsecondtick = nil end
    if self.marker then self.marker:Remove() end
    self.marker = nil
    if self.light then self.light:Remove() end
    self.light = nil
end
