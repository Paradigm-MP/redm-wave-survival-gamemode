MapSpawnPointSpawnStrategy = class(SpawnStrategy)
MapSpawnPointSpawnStrategy.spawn_delay_normal = 1500

--[[
    MapSpawnPointSpawnStrategy: spawn on map spawn points close to LocalPlayer:GetPosition()
]]

function MapSpawnPointSpawnStrategy:__init()
    self:InitializeSpawnStrategy()
    self:SetDistanceTierBiases()

    self:ProcessDelegations()
end

function MapSpawnPointSpawnStrategy:SetDistanceTierBiases()
    self.distance_tiers = {
        [1] = {min = 150, max = 170},
        [2] = {min = 130, max = 150},
        [3] = {min = 110, max = 130},
        [4] = {min = 90,  max = 110},
        [5] = {min = 70,  max = 90},
        [6] = {min = 50,  max = 70},
        [7] = {min = 30,  max = 50}
    }

    self.distance_tier_weights = {
        [1] = 2,
        [2] = 8,
        [3] = 11,
        [4] = 11,
        [5] = 5,
        [6] = 3,
        [7] = 1
    }
end

function MapSpawnPointSpawnStrategy:ProcessDelegations()
    Citizen.CreateThread(function()
        while true do
            local current_round = GameManager:GetRoundNumber()
            Wait(MapSpawnPointSpawnStrategy.spawn_delay_normal)

            if GameManager:GetIsGameInProgress() and GameManager:GetRoundNumber() == current_round
            and self:HasDelegations() then
                print("Processing a Map Spawn Point Strategy delegation")
                -- probe nearby spawn points
                local delegation_data = self:PopNextDelegation() -- assumes the delegation will be fulfilled
                --print("Delegation data:")
                --output_table(delegation_data)
                local ordered_spawn_points = SpawnManager:GetNearestSpawnPoints(LocalPlayer:GetPosition())
                local close_spawn_points = {}
                local further_spawn_points = {}

                local attempted_distance_tiers = {}
                local found_spawn_point = false
                while count_table(attempted_distance_tiers) < count_table(self.distance_tiers) do
                    local distance_tier_index = random_weighted_table_value(self.distance_tier_weights, attempted_distance_tiers)

                    local distance_tier_min = self.distance_tiers[distance_tier_index]['min']
                    local distance_tier_max = self.distance_tiers[distance_tier_index]['max']
                    local distance_tier_spawn_points = {}

                    for index, spawn_point_info in ipairs(ordered_spawn_points) do
                        local dist = spawn_point_info.distance
                        if dist > distance_tier_min and dist < distance_tier_max then
                            table.insert(distance_tier_spawn_points, spawn_point_info)
                        end
                    end

                    if count_table(distance_tier_spawn_points) > 0 then
                        local spawn_pos = random_table_value(distance_tier_spawn_points).pos
                        --Chat:Print("Picked spawn point that is " .. tostring(Vector3Math:Distance(LocalPlayer:GetPosition(), spawn_pos)) .. " away from distance tier " .. tostring(distance_tier_index))

                        local spawn_data = {
                            pos_x = spawn_pos.x,
                            pos_y = spawn_pos.y,
                            pos_z = spawn_pos.z,
                            delegation_data = delegation_data
                        }

                        SpawnManager:SpawnActor(spawn_data)
                        found_spawn_point = true
                        break
                    else
                        attempted_distance_tiers[distance_tier_index] = true
                    end
                end

                if not found_spawn_point then
                    if IsTest then
                        Chat:Print("DID NOT FIND SPAWN POINT BUT CONSUMED DELEGATION")
                    end
                end
            end
        end
    end)
end