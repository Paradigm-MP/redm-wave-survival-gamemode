GameDifficultyEnum = immediate_class(Enum)

function GameDifficultyEnum:__init()
    self:EnumInit()

    self.Easy = 1
    self:SetDescription(self.Easy, "Easy")

    self.Normal = 2
    self:SetDescription(self.Normal, "Normal")

    self.Hard = 3
    self:SetDescription(self.Hard, "Hard")

    self.Gunslinger = 4
    self:SetDescription(self.Gunslinger, "Gunslinger")
end

GameDifficultyEnum = GameDifficultyEnum()