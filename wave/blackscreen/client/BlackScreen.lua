BlackScreen = class()

function BlackScreen:__init()
    self.ui = UI:Create({name = "BlackScreen", path = "blackscreen/client/html/index.html", visible = false})
    self.visible = false
end

function BlackScreen:GetVisible()
    return self.visible
end

function BlackScreen:Show(time)
    self.ui:BringToFront()
    self.ui:Show()
    self.ui:CallEvent("blackscreen/toggle", {visible = true, time = time or 0})
    self.visible = true
end

function BlackScreen:Hide(time)
    self.ui:CallEvent("blackscreen/toggle", {visible = false, time = time or 0})
    self.visible = false
end

BlackScreen = BlackScreen()