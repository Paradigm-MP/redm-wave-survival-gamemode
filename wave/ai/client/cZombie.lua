Zombie = class(ZsActor)

function Zombie:__init()
    self:InitializeWaveSurvivalActorFromZombie() -- allow the ihnerited classes to do initialization
    self:ConfigureAgentProfile()
    self:ConfigPed()

    print("cZombie initialized successfully")
end

function Zombie:ConfigureAgentProfile()
    self.class_type = "Zombie"
end

function Zombie:ConfigPed()
    -- TODO: how to determine if the Ped is ready?
    Citizen.CreateThread(function()
        Wait(2000)
        self:Ready()
    end)
end

function Zombie:Ready()
    Chat:Debug("Entered Zombie:Ready()")

    if self:GetLocalPlayerHosted() then
        Chat:Debug("Zombie is LocalPlayerHosted()")
        self:ApplyPedConfig(RottenVZombieConfig)
        self:ApplyPedConfig(TestConfig)
        
        self:ApplyBehavior(SingleNearestTargetBehavior)
        self:ApplyBehavior(ZombiePunchBehavior) -- throws punches using self.target
        self:ApplyBehavior(RightArmHitDetectionBehavior) -- detects right-hand hits
        self:ApplyBehavior(RandomOffsetSimpleChaseBehavior) -- sets the task for the Ped to follow some entity using self.target
        self:SetReady(true)
    else
        --Chat:Print("Zombie is not LocalPlyerHosted()")
        -- config stuff that needs to be applied on all clients
    end

    self:ApplyPedConfig(SharedZombieConfig)
end

-- Behavior Event function
function Zombie:TargetSet(args)
    self.behaviors.RandomOffsetSimpleChaseBehavior:ChaseTarget()
end

-- Behavior Event function
function Zombie:PrePunch()
    self.behaviors.RightArmHitDetectionBehavior:ActivateDetection(300)
end

-- Behavior Event function
function Zombie:PostPunch()
    self.behaviors.RightArmHitDetectionBehavior:Hibernate()
    self.behaviors.RandomOffsetSimpleChaseBehavior:ChaseTarget()
end

-- LocalPlayer hosted npc logic, 50ms update function
function Zombie:AgentHostUpdate()
    
end

function Zombie:tostring()
    return "Zombie (" .. self:GetPedId() .. ")"
end