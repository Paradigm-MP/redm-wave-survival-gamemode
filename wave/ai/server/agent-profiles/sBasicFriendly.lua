BasicFriendly = class(WaveSurvivalActor)

function BasicFriendly:__init()
    self:InitializeWaveSurvivalActorFromBasicFriendly()
    self.profile_name = "BasicFriendly"
end