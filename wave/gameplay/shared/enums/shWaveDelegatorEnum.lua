WaveDelegatorEnum = immediate_class(Enum)

function WaveDelegatorEnum:__init()
    self:EnumInit()

    self.BasicEnemyWaveDelegator = 1
    self.RobotWaveDelegator = 2
    self.SwampFreakWaveDelegator = 3
    self.VampireWolfWaveDelegator = 4
    self.UndeadWaveDelegator = 5
end

if IsServer then
    function WaveDelegatorEnum:GetWaveDelegatorClass(wave_delegator_enum)
        local mapping = {
            [self.BasicEnemyWaveDelegator] = BasicEnemyWaveDelegator,
            [self.RobotWaveDelegator] = RobotWaveDelegator,
            [self.SwampFreakWaveDelegator] = SwampFreakWaveDelegator,
            [self.VampireWolfWaveDelegator] = VampireWolfWaveDelegator,
            [self.UndeadWaveDelegator] = UndeadWaveDelegator
        }

        local wave_delegator_class = mapping[wave_delegator_enum]
        
        if not wave_delegator_class then
            print("Error in WaveDelegatorEnum: no mapping for wave_delegator_enum of {", wave_delegator_enum, "}")
        end

        return wave_delegator_class
    end
end

WaveDelegatorEnum = WaveDelegatorEnum()