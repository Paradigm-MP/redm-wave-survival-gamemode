WaveTypeEnum = immediate_class(Enum)
--[[
    WaveTypeEnum: types of gamemode waves (not to do with agent profile types in waves)
]]

function WaveTypeEnum:__init()
    self:EnumInit()

    self.Quota = 1
    self:SetDescription(self.Quota, "Quota Wave")

    self.Boss = 2
    self:SetDescription(self.Boss, "Boss Wave")

    self.SurviveUntil = 3
    self:SetDescription(self.SurviveUntil, "Survive Until Wave") -- TODO: find more appropriate name?
    
end

WaveTypeEnum = WaveTypeEnum()