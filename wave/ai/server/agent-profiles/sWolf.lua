Wolf = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function Wolf:__init()
    self:InitializeWaveSurvivalActorGeneric()
    self.profile_name = "Wolf" -- not being used right now
end