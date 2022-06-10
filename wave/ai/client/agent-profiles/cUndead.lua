Undead = class(WaveSurvivalActor)

function Undead:__init()
    self:Initialize()
end

function Undead:Initialize(model)
    self.model = ActorModelEnum.Undead
    self.weapon = WeaponEnum.BrokenSword

    self:InitializeWaveSurvivalActorGeneric() -- allow the inherited classes to do initialization
    self:ConfigPed()

    --print("cBasicEnemy/Friendly initialized successfully")
    -- PLAYERDOWNED SHOULD BE IN A BEHAVIOR
    Events:Subscribe("PlayerDowned", function(args) self:PlayerDowned(args) end)
end

function Undead:ConfigPed()
    -- TODO: how to determine if the Ped is ready?
    Citizen.CreateThread(function()
        local round_spawned = GameManager:GetRoundNumber()
        Wait(5000)
        if round_spawned ~= GameManager:GetRoundNumber() then
            self:GetPed():Delete()
        end
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
            while true do
                Wait(25000)
                --ClearPedTasks()
                --TaskCombatHatedTargetsAroundPed(self:GetPedId(), 350.0, 0)
            end
        end)
    end)
end

function Undead:Ready()
    --Chat:Print("Entered Undead:Ready()")

    -- set the correct group for the NPC
    self:GetPed():SetPedActorGroup(self:GetActorGroupEnum())
    ClearPedTasksImmediately(self:GetPedId())

    -- needed to make the NPC visible
    Citizen.InvokeNative(0x283978A15512B2FE, self:GetPedId(), true)

    if self:LocalPlayerHasControl() then -- this Get call doesnt do ped natives calculations (which is good, it relies on our own data)
        --Chat:Print("BasicEnemy is LocalPlayerHosted()")
        self:ApplyPedConfig(UndeadConfig)
        --self:ApplyPedConfig(BasicEnemyConfig)
        --:ApplyPedConfig(TestConfig)
        
        --self:ApplyBehavior(BasicCombatBehavior)
        --self:ApplyBehavior(SingleNearestTargetBehavior)
        --self:ApplyBehavior(ZombiePunchBehavior) -- throws punches using self.target
        --self:ApplyBehavior(RightArmHitDetectionBehavior) -- detects right-hand hits
        --self:ApplyBehavior(RandomOffsetSimpleChaseBehavior) -- sets the task for the Ped to follow some entity using self.target

        -- TODO: disable auto-combat lol
        -- TaskCombatPed(self:GetPedId() --[[ Ped ]], LocalPlayer:GetPedId() --[[ Ped ]], 0 --[[ integer ]], 0 --[[ integer ]])
        --local weapon = WeaponEnum:GetDescription(self.weapon)
        --Chat:Debug("Spawned with weapon: " .. tostring(weapon))
        self:GetPed():RemoveAllWeapons()
        if self.weapon then
            self:GetPed():GiveWeapon(WeaponEnum:GetWeaponHash(self.weapon), 999, true)
        end
    else
        --Chat:Print("BasicEnemy is not LocalPlyerHosted()")
        -- config stuff that needs to be applied on all clients
    end

    self:SetReady(true)

    --self:ApplyPedConfig(SharedZombieConfig)
end

-- ultimately combat behavior like this should end up in a Behavior class
-- (move event subscription to a behavior class)
function Undead:PlayerDowned(args)
    -- so retarget all the peds (all hosts will run this code on their agents)
    if self:LocalPlayerHasControl() then
        Citizen.CreateThread(function()
            Wait(600)
            ClearPedTasks(self:GetPedId()) -- stops them from what they are doing immediately
            TaskCombatHatedTargetsAroundPed(self:GetPedId(), 350.0, 0)
            print("Actor Tasks Cleared and Actor tasked to combat hated targets around ped")
        end)

        print("Actor Tasks Cleared and Actor tasked to combat hated targets around ped")
    end
end

function Undead:tostring()
    return "Undead (" .. self:GetPedId() .. ")"
end