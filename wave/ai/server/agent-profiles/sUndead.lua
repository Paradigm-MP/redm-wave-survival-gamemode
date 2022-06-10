Undead = class(WaveSurvivalActor) -- BasicEnemy inherits from WaveSurvivalActor which inherits from Actor

function Undead:__init()
    self:InitializeWaveSurvivalActorGeneric()
    self.profile_name = "Undead" -- not being used right now
end