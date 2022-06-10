BasicEnemy = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function BasicEnemy:__init()
    self:InitializeWaveSurvivalActorFromBasicEnemy()
    self.profile_name = "BasicEnemy"
end