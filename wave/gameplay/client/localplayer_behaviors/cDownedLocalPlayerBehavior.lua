DownedLocalPlayerBehavior = class()
DownedLocalPlayerBehavior.name = "DownedLocalPlayerBehavior"
DownedLocalPlayerBehavior.max_down_time = 45000
DownedLocalPlayerBehavior.safe_time = 5000

--[[
    DownedLocalPlayerBehavior:
    Monitors LocalPlayer health and downs the player when health is below a certain threshold
]]

function DownedLocalPlayerBehavior:__init()
    self.downed = false    
    self.downed_health_threshold = 100 -- the health value at which the LocalPlayer goes down
    self.enforce_down_delay = 325 -- how often to enforce ragdoll state on LocalPlayer while they are downed

    self.downed_timer = Timer()

    self.last_up_timer = Timer()

    self:EnforceDownedState()

    Events:Subscribe("LocalPlayerSpawn", function(args) self:LocalPlayerSpawn(args) end)
    Events:Subscribe("LocalPlayerHealthChanged", function(args) self:LocalPlayerHealthChanged(args) end)
    Network:Subscribe("gameplay/PlayerRevived", function(args) self:PlayerRevived(args) end)
    Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)
end

-- args: old_health, new_health, damage (positive or negative)
function DownedLocalPlayerBehavior:LocalPlayerHealthChanged(args)
    --if not GameManager:GetIsGameInProgress() then return end

    if not self.downed and args.new_health <= self.downed_health_threshold then
        self.downed = true
        self.downed_timer:Restart()
        --Chat:Print("Set Player as Downed")

        -- TODO: undo this when 
        -- WORKS to stop damage from EnemyGroup
        -- blood and all sfx remain the same, but damage is not changed
        -- we dont need to worry about resetting this value on a new game because new game causes LocalPlayer:Spawn which creates a new entity
        --SetEntityCanBeDamagedByRelationshipGroup(LocalPlayer:GetPedId(), false, ActorGroupEnum:GetGroupHash(ActorGroupEnum.EnemyGroup))
        --LocalPlayer:SetIsInvincibleFromActorGroup(ActorGroupEnum.EnemyGroup, true)
        --LocalPlayer:SetIsInvincibleFromActorGroup(ActorGroupEnum.PlayerGroup, true)
        LocalPlayer:SetHealth(LocalPlayer.base_health)
        Citizen.CreateThread(function()
            Wait(25)
            LocalPlayer:SetTotallyInvincible(true)
        end)

        -- make sure ragdolling will work
        SetPedCanRagdoll(LocalPlayer:GetPedId(), true)

        -- sets the player to the DownedPlayerGroup
        -- the next time that the Peds get the TaskCombatHatedTargetsAroundPed task (when SetNetworkValue "Downed" gets to client), then LocalPlayer wont be in the hated list anymore
        -- so they will attack the other remaining players
        --SetPedRelationshipGroupHash(LocalPlayer:GetPedId(), ActorGroupEnum:GetGroupHash(ActorGroupEnum.DownedPlayerGroup))
        LocalPlayer:SetActorGroup(ActorGroupEnum.DownedPlayerGroup)

        Network:Send("gameplay/PlayerDowned", {})
    end
end

function DownedLocalPlayerBehavior:EnforceDownedState()
    Citizen.CreateThread(function()
        while true do

            if self.downed then
                SetPedToRagdoll(LocalPlayer:GetPedId(), -1, -1, 0, 0, 0, 0)

                if self.downed_timer:GetMilliseconds() > DownedLocalPlayerBehavior.max_down_time then
                    -- Kill the player
                    --Chat:Print("KILLED BY DOWNED CODE")
                    self.downed = false
                    LocalPlayer:SetTotallyInvincible(false)
                    Citizen.CreateThread(function()
                        Wait(25)
                        LocalPlayer:SetHealth(0)
                    end)
                end

                -- TODO: try ResetPedRagdollTimer(LocalPlayer:GetPedId()) instead
                -- ResetPedRagdollTimer works but stops the ped from rolling around
            end
            Wait(self.enforce_down_delay)
        end
    end)
end

-- player_unique_id, reviver_unique_id
function DownedLocalPlayerBehavior:PlayerRevived(args)
    local revived_player = cPlayers:GetByUniqueId(args.player_unique_id)

    if revived_player and LocalPlayer:IsPlayer(revived_player) then
        --print("Set downed to false")
        self.downed = false

        if GameManager:GetIsGameInProgress() then
            -- these functions affect Entity so only necessary in-game
            LocalPlayer:SetActorGroup(ActorGroupEnum.PlayerGroup)
            LocalPlayer:StopRagdollImmediately()
            --:SetHealth(math.floor(LocalPlayer.base_health * .75)) -- wouldnt work anyway because are invincible
            
            Citizen.CreateThread(function()
                Wait(5000)

                if GameManager:GetIsGameInProgress() then
                    LocalPlayer:SetTotallyInvincible(false)
                end
            end)
        end
    end
end

function DownedLocalPlayerBehavior:PlayerNetworkValueChanged(args)
    if args.name ~= "Downed" then return end

    -- Got up from downed
    if args.val == false then
        LocalPlayer.behaviors.ReviveLocalPlayerBehavior:RemoveDownedPlayer(args.player:GetUniqueId())
        
        -- This is the localplayer
        if LocalPlayer:IsPlayer(args.player) then
            self:PlayerRevived({
                player_unique_id = args.player:GetUniqueId()
            })
        end
    end

end

function DownedLocalPlayerBehavior:LocalPlayerSpawn(args)
    -- this is necessary since the ragdoll is applied to LocalPlayer ped which is dynamically fetched 
    -- (respawn doesnt make downed behavior go away because self.downed enforces it)
    self.downed = false
end

function DownedLocalPlayerBehavior:SetDowned(downed)
    self.downed = downed
end