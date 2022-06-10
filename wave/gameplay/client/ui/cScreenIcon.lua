ScreenIcon = class()

local screen_icon_id = 1

-- Unbounded if it can go off the screen, bounded if it always stays on screen
ScreenIconTypes = {Unbounded = 1, Bounded = 2}
ScreenIconImageTypes = {Weapon = "weapon", Help = "cross", Powerup = "powerup", Armor = "armor"}

--[[
    Creates a new ScreenIcon

    args (in table)
        type: ScreenIconTypes
        image_type: ScreenIconImageTypes
]]
function ScreenIcon:__init(args)
    self.id = screen_icon_id
    self.type = args.type
    self.icon = args.image_type
    self.position = nil
    self.ui = GamePlayUI:GetUI()
    self.visible = false
    screen_icon_id = screen_icon_id + 1

    self.ui:CallEvent('gameplayui/screenicon/create', 
        {id = self.id, icon = self.icon, is_localplayer = args.is_localplayer == true})
end

function ScreenIcon:Show()
    self.visible = true
    self.ui:CallEvent('gameplayui/screenicon/show', {id = self.id})
end

function ScreenIcon:Hide()
    self.visible = false
    self.ui:CallEvent('gameplayui/screenicon/hide', {id = self.id})
end

function ScreenIcon:GetVisible()
    return self.visible
end

function ScreenIcon:GetType()
    return self.type
end

function ScreenIcon:SetPosition(pos)
    self.ui:CallEvent('gameplayui/screenicon/update', {id = self.id, pos = {x = pos.x, y = pos.y}})
    self.position = pos
end

function ScreenIcon:UpdateHealth(health)
    self.ui:CallEvent('gameplayui/screenicon/updatehealth', {id = self.id, health = health})
end

function ScreenIcon:Remove()
    self.ui:CallEvent('gameplayui/screenicon/remove', {id = self.id})
end
