RobotBoss = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function RobotBoss:__init()
    self:InitializeWaveSurvivalActorFromRobotBoss()
    self.profile_name = "RobotBoss" -- not being used right now
end