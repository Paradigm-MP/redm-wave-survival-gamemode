BasicRobot = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function BasicRobot:__init()
    self:InitializeWaveSurvivalActorFromBasicRobot()
    self.profile_name = "BasicRobot" -- not being used right now
end