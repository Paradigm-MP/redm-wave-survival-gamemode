Vampire = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function Vampire:__init()
    self:InitializeWaveSurvivalActorGeneric()
    self.profile_name = "Vampire" -- not being used right now
end