SwampFreak = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function SwampFreak:__init()
    self:InitializeWaveSurvivalActorGeneric()
    self.profile_name = "SwampFreak" -- not being used right now
end