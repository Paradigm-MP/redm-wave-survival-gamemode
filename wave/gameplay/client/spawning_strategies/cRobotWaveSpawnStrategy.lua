RobotWaveSpawnStrategy = class(SpawnStrategy)
RobotWaveSpawnStrategy.spawn_delay_normal = 1500

--[[
    RobotWaveSpawnStrategy: spawn on map spawn points close to LocalPlayer:GetPosition()
]]

function RobotWaveSpawnStrategy:__init()
    self:InitializeSpawnStrategy()
    self.ideal_max_spawn_point_distance = 90
    self.max_spawn_point_distance = 150

    self:ProcessDelegations()
end

function RobotWaveSpawnStrategy:ProcessDelegations()
    Citizen.CreateThread(function()
        while true do
            local current_round = GameManager:GetRoundNumber()
            Wait(RobotWaveSpawnStrategy.spawn_delay_normal)

            if GameManager:GetRoundNumber() ~= current_round then
                Chat:Print("RobotWaveSpawnStrategy operating in wrong round")
            end

            if GameManager:GetIsGameInProgress() and GameManager:GetRoundNumber() == current_round
            and self:HasDelegations() then
                --print("Processing a Map Spawn Point Strategy delegation")
                -- probe nearby spawn points
                local delegation_data = self:PopNextDelegation() -- assumes the delegation will be fulfilled
                --print("Delegation data:")
                --output_table(delegation_data)
                local nearest_spawn_points = SpawnManager:GetNearestSpawnPoints(LocalPlayer:GetPosition())
                local close_spawn_points = {}
                local further_spawn_points = {}

                for index, spawn_point_info in ipairs(nearest_spawn_points) do
                    --print(spawn_point_info.distance, " | ", spawn_point_info.pos)
                    if spawn_point_info.distance < self.ideal_max_spawn_point_distance then
                        table.insert(close_spawn_points, spawn_point_info)
                    elseif spawn_point_info.distance < self.max_spawn_point_distance then
                        table.insert(further_spawn_points, spawn_point_info)
                    end
                end

                if count_table(close_spawn_points) > 0 then
                    local random_close_spawn_point_pos = random_table_value(close_spawn_points).pos
                    local spawn_data = {
                        pos_x = random_close_spawn_point_pos.x,
                        pos_y = random_close_spawn_point_pos.y,
                        pos_z = random_close_spawn_point_pos.z,
                        delegation_data = delegation_data
                    }
                    
                    SpawnManager:SpawnActor(spawn_data)
                elseif count_table(further_spawn_points) > 0 then
                    local random_close_spawn_point_pos = random_table_value(further_spawn_points).pos
                    local spawn_data = {
                        pos_x = random_close_spawn_point_pos.x,
                        pos_y = random_close_spawn_point_pos.y,
                        pos_z = random_close_spawn_point_pos.z,
                        delegation_data = delegation_data
                    }
                    
                    SpawnManager:SpawnActor(spawn_data)
                end
            end
        end
    end)
end