WaveSurvivalActor = class(Actor)

function WaveSurvivalActor:WaveSurvivalActorInitialize()

end

function WaveSurvivalActor:InitializeWaveSurvivalActorGeneric()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromZombie()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicEnemy()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicFriendly()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicRobot()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end


function WaveSurvivalActor:InitializeWaveSurvivalActorFromRobotBoss()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end