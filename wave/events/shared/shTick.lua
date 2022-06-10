DefaultEventsTicker = class()

function DefaultEventsTicker:__init()
    self.second = 1000
    self.minute = self.second * 60
    self.hour = self.minute * 60

    Citizen.CreateThread(function()
        while true do
            Wait(self.second)
            Events:Fire("SecondTick")
        end
    end)
    
    Citizen.CreateThread(function()
        while true do
            Wait(self.minute)
            Events:Fire("MinuteTick")
        end
    end)
    
    Citizen.CreateThread(function()
        while true do
            Wait(self.hour)
            Events:Fire("HourTick")
        end
    end)
end

DefaultEventsTicker = DefaultEventsTicker()