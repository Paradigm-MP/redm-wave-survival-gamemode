--[[
BasicFriendly = class(BasicEnemy)

function BasicFriendly:__init()
    self.model = "CS_dutch"
    self:InitializeBasicEnemyFromBasicFriendly(self.model)

    self:KeepFriendly()
end

function BasicFriendly:KeepFriendly()
    Citizen.CreateThread(function()
        while true do
            Wait(1000)

            if self:GetReady() and self:LocalPlayerHasControl() then
                --(self:GetPedId())
                --SetBlockingOfNonTemporaryEvents(self:GetPedId(), true)
                --print("Applied thing")
            end
        end
    end)
end
]]