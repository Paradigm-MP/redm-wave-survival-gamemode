WaveDelegator = class()

function WaveDelegator:InitializeWaveDelegator(wave_type_enum)
    getter_setter(self, "active") -- declares WaveDelegator:GetActive() and WaveDelegator:SetActive()
    getter_setter(self, "wave_type_enum") -- declares WaveTypeEnum:GetWaveTypeEnum() and WaveTypeEnum:SetWaveTypeEnum()
    self.round_timer = Timer()

    self:SetWaveTypeEnum(wave_type_enum)
end

function WaveDelegator:IsSurviveUntilRound()
    return self:GetWaveTypeEnum() == WaveTypeEnum.SurviveUntil
end

function WaveDelegator:IsBossRound()
    return self:GetWaveTypeEnum() == WaveTypeEnum.Boss
end