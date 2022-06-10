RestrictAreaLocalPlayerBehavior = class()
RestrictAreaLocalPlayerBehavior.name = "RestrictAreaLocalPlayerBehavior"

function RestrictAreaLocalPlayerBehavior:__init()
    self.check_pos_delay = 5000

    self.too_far_ticks = 0
    self.too_far_ticks_max = 3

    self:MonitorPosition()

    Network:Subscribe("game/sync/start", function(args) self:StartGame(args) end)
end

function RestrictAreaLocalPlayerBehavior:StartGame(args)
    self.map_name = args.mapname
    self.area = LobbyManager:GetMapData()[args.mapname].gameArea
    self.area.center = vector3(self.area.center.x, self.area.center.y, self.area.center.z)
    
    self.too_far_ticks = 0
    GamePlayUI:HideOutOfBoundsIndicator()
end

function RestrictAreaLocalPlayerBehavior:MonitorPosition()
    Citizen.CreateThread(function()
        while true do
            Wait(self.check_pos_delay)

            if GameManager:GetIsGameInProgress() then
                local localplayer_pos = LocalPlayer:GetPosition()

                local distance = Vector3Math:Distance(self.area.center, localplayer_pos)
                
                if distance > self.area.radius then
                    self.too_far_ticks = self.too_far_ticks + 1
                    GamePlayUI:ShowOutOfBoundsIndicator(
                        "Return to " .. tostring(self.map_name) .. " to continue playing!")
                    if self.too_far_ticks > self.too_far_ticks_max then
                        self:RespawnLocalPlayer()
                        Wait(10000)
                    end
                else
                    self.too_far_ticks = 0
                    GamePlayUI:HideOutOfBoundsIndicator()
                end

                if distance > self.area.radius * 1.5 then
                    self:RespawnLocalPlayer()
                    Wait(10000)
                end
            end
        end
    end)
end

function RestrictAreaLocalPlayerBehavior:RespawnLocalPlayer()
    -- Restore the HP that they had if they are respawned
    LocalPlayer:SetPosition(GameManager:GetRandomPlayerSpawnPoint())
    self.too_far_ticks = 0
    GamePlayUI:HideOutOfBoundsIndicator()
end