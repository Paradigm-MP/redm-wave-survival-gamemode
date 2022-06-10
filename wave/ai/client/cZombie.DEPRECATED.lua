Zombie = class(ZsActor)

function Zombie:__init()
    self:Initialize() -- call our parent (Actor class) "constructor" that we inherited
    self:Configure()
    print("cZombie initialized successfully")

    self:ListenForEvents()
    
    self.leap_ticks = 0
    self.leap_tick_delay = 2
end

function Zombie:SetCorrectRelationships()
    AddRelationshipGroup("Zombies1")
    --SetRelationshipBetweenGroups(5, GetHashKey('PLAYER'), GetHashKey("Zombies1"))
    --SetRelationshipBetweenGroups(5, GetHashKey("Zombies1"), GetHashKey('PLAYER'))

    SetPedRelationshipGroupHash(self.ped_id, GetHashKey("Zombies1"))
end

function Zombie:ListenForEvents()
    Citizen.CreateThread(function()
        Wait(1000)

        if not self:EnsurePedAccess() then
            print("------- No Ped Access in cZombie ------")
        end

        self:RottenVRemadeZombieConfig()
        self:ApplyTestConfig()
        self:SetCorrectRelationships()

        while true do
            Wait(100)
        end
    end)
end

function Zombie:RottenVRemadeZombieConfig()
    local ped = self.ped_id
    SetPedArmour(ped, 100)
	SetPedAccuracy(ped, 25)
	SetPedSeeingRange(ped, 100.0)
	SetPedHearingRange(ped, 80.0)

    SetPedFleeAttributes(ped, 0, 0)
    SetPedCombatAttributes(ped, 16, 1)
    SetPedCombatAttributes(ped, 17, 0)
    SetPedCombatAttributes(ped, 46, 1)
    SetPedCombatAttributes(ped, 1424, 0)
    SetPedCombatAttributes(ped, 5, 1)
    SetPedCombatRange(ped,2)
    SetPedAlertness(ped,3)
    SetAmbientVoiceName(ped, "ALIENS")
    SetPedEnableWeaponBlocking(ped, true)
    SetPedRelationshipGroupHash(ped, GetHashKey("Zombies1"))
    DisablePedPainAudio(ped, true)
    SetPedDiesInWater(ped, false)
    SetPedDiesWhenInjured(ped, false)
    --	PlaceObjectOnGroundProperly(ped)
    SetPedDiesInstantlyInWater(ped, true)
    SetPedIsDrunk(ped, true)
    SetPedConfigFlag(ped,100,1)
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Wait(1)
    end
    SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)
    ApplyPedDamagePack(ped,"BigHitByVehicle", 0.0, 9.0)
    ApplyPedDamagePack(ped,"SCR_Dumpster", 0.0, 9.0)
    ApplyPedDamagePack(ped,"SCR_Torture", 0.0, 9.0)
    StopPedSpeaking(ped,true)

    --TaskWanderStandard(ped, 1.0, 10)
    local pspeed = math.random(20,70)
    local pspeed = pspeed/10
    local pspeed = pspeed+0.01
    --SetEntityMaxSpeed(ped, 5.0)

    if not NetworkGetEntityIsNetworked(ped) then
        NetworkRegisterEntityAsNetworked(ped)
    end
end

function Zombie:ApplyTestConfig()
    local ped = self.ped_id
    -- SetBlockingOfNonTemporaryEvents stops the ped from engaging in combat with players when shot or aimed at
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- SetPedCanRagdoll completely disables ragdolling. it causes odd immediate-drop-to-floor behavior when peds die, but otherwise works as intended. explosions act weirdly
    --SetPedCanRagdoll(ped, false)
    -- SetPedRagdollBlockingFlags stops bullets from making the ped go ragdoll
    SetPedRagdollBlockingFlags(ped, 1)

    -- SetPedCanRagdollFromPlayerImpact stops the player from being able to knock a ped down by sprinting at it
    SetPedCanRagdollFromPlayerImpact(ped, false)
end

function Zombie:Configure()
    self.classType = "Zombie"
end

function Zombie:BehaviorUpdate()
    if not self:LocalPlayerHasControl() then return end
    self:IncrementTicks()
    --print("entered BehaviorUpdate")

    if self.leap_ticks > self.leap_tick_delay then
        self.leap_ticks = 0
        self:LeapForward()
        print("tried to make zombie leap")
    end
end

function Zombie:IncrementTicks()
    self.leap_ticks = self.leap_ticks + 1
end

function Zombie:Test()
    self:IncrementTicks()

    local net_id = self:GetNetId()

    if not net_id then
        print("No net_id in update function")
        return
    end

    self.ped_id = NetToPed(net_id)

    if not self:LocalPlayerHasControl() and not self.requested_control then
        self.requested_control = true
        self:RequestLocalPlayerControl()
        return
    end

    if not self:LocalPlayerHasControl() then return end

    if self.leap_ticks > self.leap_tick_delay then
        self.leap_ticks = 0
        self:LeapForward()
        print("tried to make zombie leap.. owner is: ", cPlayers:GetByServerId(NetworkGetEntityOwner(self.ped_id)))
    end
end

function Zombie:Test2()
    self:IncrementTicks()

    local net_id = self:GetNetId()

    if not net_id then
        print("No net_id in update function")
        return
    end

    self.ped_id = NetToPed(net_id)

    --if not self:LocalPlayerHasControl() and not self.requested_control then
    --    self.requested_control = true
    --    self:RequestLocalPlayerControl()
    --    return
    --end

    if self.leap_ticks > self.leap_tick_delay then
        self.leap_ticks = 0
        self:LeapForward()
        print("tried to make zombie leap.. owner is: ", cPlayers:GetByServerId(NetworkGetEntityOwner(self.ped_id)))
    end
end