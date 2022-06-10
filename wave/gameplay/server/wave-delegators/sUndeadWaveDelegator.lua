UndeadWaveDelegator = class(WaveDelegator)
UndeadWaveDelegator.survive_until_time = 160
UndeadWaveDelegator.weather = "DRIZZLE"
UndeadWaveDelegator.hour = 23

function UndeadWaveDelegator:__init(wave_type_enum, round_data)
    self:InitializeWaveDelegator(wave_type_enum)

    self.round_data = round_data
    self.difficulty = round_data.difficulty
    self.round_number = round_data.round_number
    self.number_of_players = round_data.number_of_players
    self.spawned = 0
    self.killed = 0
    self.max_alive_at_once = 50

    self.delegations = {}

    self.last_killed_timer = Timer()

    self:Configure()
    self:Delegate()
end

function UndeadWaveDelegator:Configure()
    if self:GetWaveTypeEnum() == WaveTypeEnum.Quota then
        self.delegation_delay = 4000 / self.number_of_players
        self.spawn_quota = math.ceil(SpawnManager:GenerateRoundEnemyQuota(self.round_number, self.difficulty, self.number_of_players) * 1.8)
        self.max_alive_at_once = 60
    elseif self:GetWaveTypeEnum() == WaveTypeEnum.SurviveUntil then
        self.delegation_delay = 2000 / self.number_of_players
        -- spawn quota affects spawn rate in survive until rounds (after the quota, the spawning delay is greatly increased)
        self.spawn_quota = SpawnManager:GenerateSurviveUntilRoundEnemyQuota(self.round_number, self.difficulty, self.number_of_players)
        self.max_alive_at_once = self.spawn_quota
    end
end

function UndeadWaveDelegator:Delegate()
    Citizen.CreateThread(function()
        while self:GetActive() do
            Wait(self.delegation_delay)
            
            if self:GetActive() and GameManager:GetIsGameInProgress() then
                if self.killed < self.spawn_quota or self:IsSurviveUntilRound() then
                    local num_alive = self:GetNumberAlive()
                    if num_alive < self.max_alive_at_once then
                        -- extra delay if spawning extras
                        if self.spawned > math.floor(self.spawn_quota * 1.1) then
                            Wait(8000)
                        end

                        self:DelegatePlayer()
                    end
                end
            end
        end
    end)
    
    if self:IsSurviveUntilRound() then
        Citizen.CreateThread(function()
            while self:GetActive() do
                Wait(500)
                
                if self:GetActive() and GameManager:GetIsGameInProgress() then
                    self:CheckForEndOfRound()
                end
            end
        end)
    end
end

function UndeadWaveDelegator:DelegatePlayer()
    if not self:GetActive() or not GameManager:GetIsGameInProgress() then return end
    local game_info = GameManager:GetGameInfo()

    -- pick a player to delegate spawning to
    local alive_players = GameManager:GetAlivePlayers()
    local least_delegations = 99999999
    local least_delegated_to_player

    for id, player in pairs(alive_players) do
        local player_id = player:GetUniqueId()
        if not self.delegations[player_id] then
            self.delegations[player_id] = 0

            least_delegated_to_player = player
            least_delegations = 0
        else
            if self.delegations[player_id] < least_delegations then
                least_delegated_to_player = player
                least_delegations = self.delegations[player_id]
            end
        end
    end

    if least_delegated_to_player then
        --print("least delegated to player: ", least_delegated_to_player)
        Network:Send("gameplay/DelegateActorSpawn", least_delegated_to_player:GetId(), {
            spawn_strategy_enum = SpawnStrategyEnum.MapSpawnPoints,
            delegation_data = {
                agent_profile_enum = AgentProfileEnum.Undead,
                actor_group_enum = ActorGroupEnum.EnemyGroup
            }
        })

        self.delegations[least_delegated_to_player:GetUniqueId()] = self.delegations[least_delegated_to_player:GetUniqueId()] + 1
        self.spawned = self.spawned + 1
    else
        print("Error - no least delegated to player")
    end
end

-- args.killer not guaranteed
function UndeadWaveDelegator:ActorKilled(args)
    if not args.actor:GetActorGroup() == ActorGroupEnum.EnemyGroup then return end

    self.killed = self.killed + 1
    self.last_killed_timer = Timer()

    if args.killer_type == "Player" and args.killer then
        -- remove the outstanding delegation
        local killer_unique_id = args.killer:GetUniqueId()
        if self.delegations[killer_unique_id] ~= nil and self.delegations[killer_unique_id] > 0 then
            self.delegations[killer_unique_id] = self.delegations[killer_unique_id] - 1
        end
    end

    print(args.actor, " died")
    print("Actors Killed vs. Quota: ", self.killed, " / ", self.spawn_quota)

    self:CheckForEndOfRound()
end

function UndeadWaveDelegator:PlayerQuit(args)
    local player_unique_id = args.player:GetUniqueId()

    if self.delegations[player_unique_id] ~= nil and self.delegations[player_unique_id] > 0 then
        local lost_delegations = self.delegations[player_unique_id]
        self.spawned = self.spawned - lost_delegations
    end
end

function UndeadWaveDelegator:CheckForEndOfRound()
    if GameManager:GetRoundNumber() == self.round_number then
        if self:IsSurviveUntilRound() and self.round_timer:GetSeconds() > UndeadWaveDelegator.survive_until_time then
            Chat:Broadcast({text = "Survived until survive-until time on basic enemy wave on round#" .. tostring(self.round_number)})
            self:SetActive(false)
            GameManager:NewRound()
        elseif not self:IsSurviveUntilRound() then
            if self.killed >= self.spawn_quota then
                Chat:Broadcast({text = "Reached quota on basic enemy wave"})
                self:SetActive(false)
                GameManager:NewRound()
            end
        end
    else
        Chat:Broadcast({text = "UndeadWaveDelegator checking for end of round in wrong round"})
    end
end

function UndeadWaveDelegator:GetNumberAlive()
    return self.spawned - self.killed
end

function UndeadWaveDelegator:tostring()
    return "UndeadWaveDelegator #" .. tostring(self.round_number) .. " (" .. WaveTypeEnum:GetDescription(self:GetWaveTypeEnum()) .. ")"
end