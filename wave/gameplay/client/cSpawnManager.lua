SpawnManager = class()

function SpawnManager:__init()
    self.spawn_points = {}
    self:DeclareSpawnStrategies()

    if IsTest then
        Events:Subscribe("Render", function() self:RenderDebug() end)
    end
    

    Events:Subscribe("NewRound", function(args) self:NewRound(args) end)
    Events:Subscribe("GameEnd", function(args) self:GameEnd(args) end)

    Network:Subscribe("gameplay/DelegateEnemySpawn", function(data) self:DelegateEnemySpawn(data) end)
    Network:Subscribe("gameplay/DelegateFriendlySpawn", function(args) self:DelegateFriendlySpawn(args) end)
    Network:Subscribe("gameplay/DelegateActorSpawn", function(args) self:DelegateActorSpawn(args) end)
end

function SpawnManager:DeclareSpawnStrategies()
    -- TODO: replace this mapping and others (enum -> class instance)
    -- with a standardized solution for this problem
    self.spawn_strategy_mapping = {
        [SpawnStrategyEnum.MapSpawnPoints] = MapSpawnPointSpawnStrategy,
        [SpawnStrategyEnum.LocalPlayerPosition] = LocalPlayerPositionSpawnStrategy,
        [SpawnStrategyEnum.RobotWave] = RobotWaveSpawnStrategy,
        [SpawnStrategyEnum.RobotBossWave] = RobotBossSpawnStrategy
    }

    self.spawn_strategies = {}
    --self.spawn_strategies[SpawnStrategyEnum.SpawnStrategyEnum] = MapSpawnPointSpawnStrategy()
    --self.spawn_strategies.LocalPlayerPositionSpawnStrategy = LocalPlayerPositionSpawnStrategy()
end

function SpawnManager:DelegateActorSpawn(args)
    if self.spawn_strategy_mapping[args.spawn_strategy_enum] then
        SpawnManager:InitializeSpawnStrategyIfNecessary(args.spawn_strategy_enum)
        SpawnManager:AcceptDelegation(args.spawn_strategy_enum, args.delegation_data)
    else
        print("SpawnManager error: spawn strategy not found in mapping")
    end
end

function SpawnManager:InitializeSpawnStrategyIfNecessary(spawn_strategy_enum)
    if self.spawn_strategy_mapping[spawn_strategy_enum] and not self.spawn_strategies[spawn_strategy_enum] then
        local spawn_strategy_class = self.spawn_strategy_mapping[spawn_strategy_enum]
        local spawn_strategy_instance = spawn_strategy_class()
        self.spawn_strategies[spawn_strategy_enum] = spawn_strategy_instance
    end
end

function SpawnManager:AcceptDelegation(spawn_strategy_enum, delegation_data)
    if self.spawn_strategies[spawn_strategy_enum] then
        local spawn_strategy = self.spawn_strategies[spawn_strategy_enum]
        spawn_strategy:AcceptDelegation(delegation_data)
    else
        print("Spawnmanager error: Tried to accept delegation but spawn strategy not initialized")
    end
end

function SpawnManager:ClearAllDelegations()
    for spawn_strategy_enum, spawn_strategy in pairs(self.spawn_strategies) do
        spawn_strategy:ClearDelegations()
    end
end

function SpawnManager:NewRound()
    SpawnManager:ClearAllDelegations()
end

function SpawnManager:GameEnd()
    SpawnManager:ClearAllDelegations()
end

function SpawnManager:NewGame(map_data)
    self.spawn_points = {}
    for k, position_table in pairs(map_data.enemySpawnPoints) do
        local pos = vector3(position_table.pos.x, position_table.pos.y, position_table.pos.z)
        table.insert(self.spawn_points, pos)
    end

    self.boss_spawn_points = {}
    if map_data.bossSpawnPoints then
        for k, position_table in pairs(map_data.bossSpawnPoints) do
            local pos = vector3(position_table.pos.x, position_table.pos.y, position_table.pos.z)
            table.insert(self.boss_spawn_points, pos)
        end
    end
end

function SpawnManager:RenderDebug()
    if self.spawn_points then
        --[[
        -- Rendering boss spawn points
        if GameManager:GetWaveType() == WaveTypeEnum.Boss then
            if self.boss_spawn_points then
                for k, pos in pairs(self.boss_spawn_points) do
                    Render:DrawText(Render:WorldToScreen(pos + vector3(0, 0, 1.5)), tostring(k), Colors.Tomato, 1, 1)
                end
            end
        end
        ]]
        --local dist
        --local localplayer_pos = LocalPlayer:GetPosition()
        --for k, spawn_pos in pairs(self.spawn_points) do
            --dist = Vector3Math:Distance(localplayer_pos, spawn_pos)
            --Render:DrawText(Render:WorldToScreen(spawn_pos + vector3(0, 0, 1.5)), tostring(k), Colors.Tomato, 1, 1)
            --Render:DrawText(Render:WorldToScreen(spawn_pos + vector3(0, 0, 2.5)), tostring(dist), Colors.Tomato, 0.5, 0.5)

            --local eye_height_spawn_pos = spawn_pos + vector3(0, 0, 1.72)
            --Render:DrawText(Render:WorldToScreen(spawn_pos + vector3(0, 0, 2.5)), tostring(visible and "visible" or "NOT visible"), Colors.Tomato, 0.5, 0.5)
            --[[
            for id, player in pairs(GameManager:GetAlivePlayers()) do
                -- x, y, z, radius, player_id, ?     NO
                -- ?, x, y, z, radius, player_id     NO
                -- player_id, x, y, z, radius, ?     NO
                -- ?, player_id, x, y, z, radius
                local visible = IsSphereVisibleToPlayer(
                    player.player_id,
                    eye_height_spawn_pos.x,
                    eye_height_spawn_pos.z,
                    eye_height_spawn_pos.y,
                    0.5
                )
                -- TODO: figure out how to see if the npc is visible to OTHER players or not, or sync this info on a regular basis with all the players
                Render:DrawText(Render:WorldToScreen(spawn_pos + vector3(0, 0, 2.5)), player:GetName() .. ": " .. tostring(visible and "visible" or "NOT visible"), Colors.Tomato, 0.5, 0.5)
            end
            ]]
        --end
    end
end

function SpawnManager:SpawnActor(spawn_data)
    Network:Send("gameplay/SpawnActor", {x = spawn_data.pos_x, y = spawn_data.pos_y, z = spawn_data.pos_z, 
        delegation_data = spawn_data.delegation_data
    })
end

-- returns an ordered sequential table of spawn points
-- based on the distance between position parameter and the spawn point position
-- closest spawn point is first in the table, farthest is last
function SpawnManager:GetNearestSpawnPoints(position)
    local ordered_spawn_points = {}

    for k, pos in ipairs(self.spawn_points) do
        table.insert(ordered_spawn_points, {pos = pos, distance = Vector3Math:Distance(pos, position)})
    end

    table.sort(ordered_spawn_points, function(a, b)
        return a.distance < b.distance
    end)

    return ordered_spawn_points
end


-- returns an ordered sequential table of spawn points
-- based on the distance between position parameter and the spawn point position
-- closest spawn point is first in the table, farthest is last
function SpawnManager:GetNearestBossSpawnPoints(position)
    local ordered_spawn_points = {}

    for k, pos in ipairs(self.boss_spawn_points) do
        table.insert(ordered_spawn_points, {pos = pos, distance = Vector3Math:Distance(pos, position)})
    end

    table.sort(ordered_spawn_points, function(a, b)
        return a.distance < b.distance
    end)

    return ordered_spawn_points
end

SpawnManager = SpawnManager()