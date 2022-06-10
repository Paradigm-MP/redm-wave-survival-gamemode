IconManager = class()

function IconManager:__init()
    self.icons = {}

    self:CheckIfInRange()
    self:TickFast()
end

function IconManager:TickFast()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            for id, data in pairs(self.icons) do
                if data.in_range then

                    local pos, on_screen 
                    if data.screen_icon:GetType() == ScreenIconTypes.Unbounded then
                        pos, on_screen = Render:WorldToScreen(data.position)
                    elseif data.screen_icon:GetType() == ScreenIconTypes.Bounded then
                        on_screen = true
                        pos = Render:WorldToHud(data.position)
                    end

                    if not on_screen then
                        data.screen_icon:Hide()
                    else
                        if not data.screen_icon:GetVisible() then
                            data.screen_icon:Show()
                        end
                        data.screen_icon:SetPosition(pos)
                    end
                end
            end
        end
    end)
end

function IconManager:CheckIfInRange()
    Citizen.CreateThread(function()
        while true do
            local pos = LocalPlayer:GetPosition()
            for id, data in pairs(self.icons) do
                local in_range = Vector3Math:Distance(data.position, pos) < data.range
                data.in_range = in_range
                if not in_range then
                    data.screen_icon:Hide()
                end
                Citizen.Wait(10)
            end
            Citizen.Wait(1000)
        end
    end)
end

--[[
    Adds a new icon to the icon manager.

    args (in table)
        screen_icon: ScreenIcon
        position: vector3
        range: number to show the indicator in
]]
function IconManager:Add(args)
    self.icons[args.screen_icon.id] = 
    {
        screen_icon = args.screen_icon,
        range = args.range,
        position = args.position,
        in_range = false
    }
end

function IconManager:Remove(id)
    if not self.icons[id] then return end
    self.icons[id].screen_icon:Remove()
    self.icons[id] = nil
end

function IconManager:UpdatePosition(id, pos)
    if not self.icons[id] then return end
    self.icons[id].position = pos
end

function IconManager:Clear()
    for id, data in pairs(self.icons) do
        data.screen_icon:Remove()
    end
    self.icons = {}
end

IconManager = IconManager()