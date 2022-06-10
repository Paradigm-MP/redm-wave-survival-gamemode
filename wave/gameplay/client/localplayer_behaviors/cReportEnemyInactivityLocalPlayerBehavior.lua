ReportEnemyInactivityLocalPlayerBehavior = class()
ReportEnemyInactivityLocalPlayerBehavior.name = "ReportEnemyInactivityLocalPlayerBehavior"

--[[
    ReportEnemyInactivityLocalPlayerBehavior:
    Reports to the server if no enemies are attacking
]]

function ReportEnemyInactivityLocalPlayerBehavior:__init()
    self.current_round = 1
    self.round_start_timer = Timer()

    -- certain events in the world will reset the enemy inactivity timer
    self.inactivity_timer = Timer()
    self.inactivity_check_delay = 5000
    self.max_inactivity_time = 40 -- seconds

    self.last_damaged_bone = 0

    self:CheckForInactivity()
    self:MonitorDamage()

    Events:Subscribe("NewRound", function(args) self:NewRound(args) end)
    Events:Subscribe("ActorSpawned", function(args) self:ActorSpawned(args) end)
end


-- args: old_health, new_health, damage (positive or negative)

function ReportEnemyInactivityLocalPlayerBehavior:CheckForInactivity()
    Citizen.CreateThread(function()
        while true do
            Wait(self.inactivity_check_delay)
            self:InactivityCheck()
        end
    end)
end

function ReportEnemyInactivityLocalPlayerBehavior:MonitorDamage()
    Citizen.CreateThread(function()
        while true do
            Wait(350)
            self:CheckForDamage()
        end
    end)
end

function ReportEnemyInactivityLocalPlayerBehavior:CheckForDamage()
    local localplayer_ped = LocalPlayer:GetPedId()
    local success, bone = GetPedLastDamageBone(localplayer_ped)
    -- success seems to always return 1 .. oh well
    -- also ClearPedLastDamageBone doesnt seem to do anything

    if success then
        if bone ~= self.last_damaged_bone then
            -- detected some damage to some bone
            -- doesnt trigger for fall damage

            self.inactivity_timer:Restart()
            --Chat:Print("Reset due to damage")
        end

        self.last_damaged_bone = bone
    end
end

function ReportEnemyInactivityLocalPlayerBehavior:InactivityCheck()
    --print(GameManager:GetIsGameInProgress(), " ", SpectateMode:GetIsSpectating(), " ", self.round_start_timer:GetSeconds(), " ", self.inactivity_timer:GetSeconds())
    
    if not GameManager:GetIsGameInProgress() or SpectateMode:GetIsSpectating() then
        self.round_start_timer:Restart()
        self.inactivity_timer:Restart()
    end

    if not GameManager:GetIsGameInProgress() then return end
    if SpectateMode:GetIsSpectating() then return end
    if self.round_start_timer:GetSeconds() < (math.floor(60 + (self.current_round * 1.1))) then return end
    if self.inactivity_timer:GetSeconds() < self.max_inactivity_time then return end

    self:InactiveAction()
end

function ReportEnemyInactivityLocalPlayerBehavior:InactiveAction()
    self.round_start_timer:Restart()
    self.inactivity_timer:Restart()

    Chat:Debug("-----------------------------")
    Chat:Debug("-- LocalPlayer InactivityDetected --")
    Chat:Debug("-----------------------------")

    Network:Send("InactivityDetected")
end

function ReportEnemyInactivityLocalPlayerBehavior:ActorSpawned(args)
    self.inactivity_timer:Restart()
    --Chat:Print("Reset due to Actor Spawned")
end

function ReportEnemyInactivityLocalPlayerBehavior:NewRound(args)
    self.current_round = args.round_number
    self.round_start_timer:Restart()
    self.inactivity_timer:Restart()
    --Chat:Print("Reset due to new round")
end