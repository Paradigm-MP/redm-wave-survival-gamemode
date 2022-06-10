BasicFriendly = class(WaveSurvivalActor)

function BasicFriendly:__init()
    self:Initialize()
end

function BasicFriendly:Initialize(model)
    self.model = ActorModelEnum.Test
    self.weapon = WeaponEnum.Machete

    self:InitializeWaveSurvivalActorFromBasicFriendly() -- allow the ihnerited classes to do initialization
    self:ConfigPed()

end

function BasicFriendly:ConfigPed()
    -- TODO: how to determine if the Ped is ready?
    Citizen.CreateThread(function()
        Wait(5000)
        self:Ready()

        --Citizen.CreateThread(function() end)
        -- this works to make the peds attack hated targets
        -- not test in multiplayer which means that technically this is only proven to make peds attack their host
        -- TODO: set this task periodically in case it doesnt get applied after Ready() because maybe the ped wasnt actually ready so then the task wouldnt be set
        --TaskCombatHatedTargetsAroundPed(self:GetPedId(), 350.0, 0)

        -- one problem with resetting the task periodically is that it will disrupt the actor's behavior and change it significantly
        -- so lets try to avoid changing the taWsk too often

        Citizen.CreateThread(function()
            TaskCombatHatedTargetsAroundPed(self:GetPedId(), 350.0, 0) -- TODO: re-enable this
            self:GetPed():SetScale(2)
            --SetPedScale(self:GetPedId(), 5)
            while true do
                Wait(25000)

                --ClearPedTasks()
                --TaskCombatHatedTargetsAroundPed(self:GetPedId(), 350.0, 0)
            end
        end)
    end)
end

function BasicFriendly:Ready()
    --Chat:Print("Entered BasicFriendly:Ready()")

    -- set the correct group for the NPC
    --Chat:Print("Friendly Actor Group: " .. tostring(ActorGroupEnum:GetDescription(self:GetActorGroupEnum())))
    self:GetPed():SetPedActorGroup(self:GetActorGroupEnum())
    ClearPedTasksImmediately(self:GetPedId())

    -- TODO: figure out if we need to use this
    --if GetRelationshipBetweenPeds(self:GetPedId(), LocalPlayer:GetPedId()) == 0 then
        -- SetBlockingOfNonTemporaryEvents() is necessary, otherwise friendlies will attack the player if the player shoots near them
        --SetBlockingOfNonTemporaryEvents(self:GetPedId(), true)
        --SetPedCanBeTargettedByPlayer(self:GetPedId(), PlayerId(), false)
    --else
    --    SetPedCanBeTargettedByPlayer(self:GetPedId(), PlayerId(), true)
    --end

    -- needed to make the NPC visible
    Citizen.InvokeNative(0x283978A15512B2FE, self:GetPedId(), true)

    if self:LocalPlayerHasControl() or self:GetLocalPlayerHosted() then
        --self:ApplyPedConfig(RottenVZombieConfig)
        self:ApplyPedConfig(BasicFriendlyConfig)
        --:ApplyPedConfig(TestConfig)
        
        --self:ApplyBehavior(BasicCombatBehavior)
        --self:ApplyBehavior(SingleNearestTargetBehavior)
        --self:ApplyBehavior(ZombiePunchBehavior) -- throws punches using self.target
        --self:ApplyBehavior(RightArmHitDetectionBehavior) -- detects right-hand hits
        --self:ApplyBehavior(RandomOffsetSimpleChaseBehavior) -- sets the task for the Ped to follow some entity using self.target

        -- TODO: disable auto-combat lol
        -- TaskCombatPed(self:GetPedId() --[[ Ped ]], LocalPlayer:GetPedId() --[[ Ped ]], 0 --[[ integer ]], 0 --[[ integer ]])
        if self.weapon then
            local weapon = WeaponEnum:GetDescription(self.weapon)
            Chat:Debug("Spawned Friendly with weapon: " .. tostring(weapon))
            self:GetPed():RemoveAllWeapons()
            self:GetPed():GiveWeapon(WeaponEnum:GetWeaponHash(self.weapon), 999, true)
        end
    end

    self:SetReady(true)

    --self:ApplyPedConfig(SharedZombieConfig)
end

-- Behavior Event function
function BasicFriendly:TargetSet(args)
    --self.behaviors.RandomOffsetSimpleChaseBehavior:ChaseTarget()
end

-- Behavior Event function
function BasicFriendly:PrePunch()
    --self.behaviors.RightArmHitDetectionBehavior:ActivateDetection(300)
end

-- Behavior Event function
function BasicFriendly:PostPunch()
    --self.behaviors.RightArmHitDetectionBehavior:Hibernate()
    --self.behaviors.RandomOffsetSimpleChaseBehavior:ChaseTarget()
end

-- LocalPlayer hosted npc logic, 50ms update function
function BasicFriendly:AgentHostUpdate()
    
end

function BasicFriendly:tostring()
    return "BasicEnemy (" .. self:GetPedId() .. ")"
end