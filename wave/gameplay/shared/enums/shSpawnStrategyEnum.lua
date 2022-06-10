SpawnStrategyEnum = immediate_class(Enum)

function SpawnStrategyEnum:__init()
    self:EnumInit()

    self.MapSpawnPoints = 1 -- spawn on a nearby map spawn point
    self.LocalPlayerPosition = 2 -- spawn next to LocalPlayer position
    self.RobotWave = 3 -- spawn next to LocalPlayer position

    -- this could be generalized into a more simple "BossSpawnPoints" spawn strategy
    -- but we could also make custom ones even if they use the boss spawn points if we need additional customization
    self.RobotBossWave = 4 -- spawn on nearby boss spawn point
end

function SpawnStrategyEnum:GetClassFromEnum()
    --local mapping = {
    --    [self.MapSpawnPoints] = MapSpawnPointSpawnStr
    ---}
    -- TODO: implement real-time mapping here
end

SpawnStrategyEnum = SpawnStrategyEnum()