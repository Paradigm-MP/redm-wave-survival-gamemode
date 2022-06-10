SpawnManager = class()
SpawnManager.special_round_chance = 40 -- 0 <-> 100 percentage chance of a special wave (once every 3 rounds)
SpawnManager.boss_round_chance = 30 -- 0 <-> 100 percentage chance of a boss wave (once every 5 rounds)
SpawnManager.survive_until_chance_on_special_round = 30 -- 0 <-> 100 percentage chance of a special round being a survive-until round
SpawnManager.survive_until_chance_on_normal_round = 10 -- 0 <-> 100 percentage chance of a special round being a survive-until round
SpawnManager.single_weapon_round_chance = 15

function SpawnManager:__init()

    self:HandleNetworkEvents()
    self:HandleEvents()
end

-- for test commands
function SpawnManager:PlayerChat(args)
    
end

function SpawnManager:SetActive(active)
    self.delegator:SetActive(active)
end

function SpawnManager:HandleNetworkEvents()
    Network:Subscribe("gameplay/SpawnActor", function(args) self:SpawnActor(args) end)
    Network:Subscribe("InactivityDetected", function(args) self:InactivityDetected(args) end)
end

function SpawnManager:HandleEvents()
    Events:Subscribe("ActorKilled", function(args) self:ActorKilled(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
    Events:Subscribe("GameEnd", function(args) self:GameEnd(args) end)

    if IsTest then
        Events:Subscribe("ChatMessage", function(args) return self:PlayerChat(args) end)
    end

    Network:Subscribe("NextRound", function(args)
        GameManager:NewRound()
    end)
end

-- how many NPCs per round based on difficulty, round number, and number of players
-- difficulty should also manifest in AI aiming and maybe other combat attributes or weapons
function SpawnManager:GenerateRoundEnemyQuota(round_number, difficulty, number_of_players)
    --local difficulty_modifiers = {
    --    [GameDifficultyEnum.Easy] = 0.85,
    --    [GameDifficultyEnum.Normal] = 1.00,
    --    [GameDifficultyEnum.Hard] = 1.20,
    --    [GameDifficultyEnum.Gunslinger] = 1.40
    --}

    local base_amount = 2

    local number_players_modifier = 1.0
    if number_of_players == 2 then number_players_modifier = 1.2 end
    if number_of_players == 3 then number_players_modifier = 1.4 end
    if number_of_players == 4 then number_players_modifier = 1.5 end
    if number_of_players == 5 then number_players_modifier = 1.6 end
    if number_of_players > 6 then number_players_modifier = 1.7 end

    return math.floor((base_amount + (round_number * 1.3)) * number_players_modifier)
    --return math.floor(base_amount + (round_number * 1.0))
    --return -1
end

function SpawnManager:GenerateSurviveUntilRoundEnemyQuota(round_number, difficulty, number_of_players)
    local base_amount = 2

    local number_players_modifier = 1.0
    if number_of_players == 2 then number_players_modifier = 1.2 end
    if number_of_players == 3 then number_players_modifier = 1.4 end
    if number_of_players == 4 then number_players_modifier = 1.5 end
    if number_of_players == 5 then number_players_modifier = 1.6 end
    if number_of_players > 6 then number_players_modifier = 1.7 end

    local spawn_quota = math.floor((base_amount + (round_number * 1.7)) * number_players_modifier)
    if spawn_quota > 80 then
        spawn_quota = 80
    end

    return spawn_quota
    --return math.floor(base_amount + (round_number * 1.0))
end

function SpawnManager:GetWaveType()
    if self.delegator then
        return self.delegator:GetWaveTypeEnum()
    else
        print("SpawnManager error: tried to GetWaveType() but self.delegator is nil")
    end
end

-- returns nil if the wave doesn't specify a weather
function SpawnManager:GetWaveWeather()
    if self.delegator_class then
        return self.delegator_class.weather
    else
        print("SpawnManager error: tried to GetWaveWeather() but self.delegator_class is nil")
    end
end

-- returns nil if the wave doesn't specify a wtime
function SpawnManager:GetWaveTime()
    if self.delegator_class then
        return self.delegator_class.hour
    else
        print("SpawnManager error: tried to GetWaveTime() but self.delegator_class is nil")
    end
end

function SpawnManager:GetSurviveUntilTime()
    return self.survive_until_time
end

function SpawnManager:GenerateWave(round_data)
    local round_number = round_data.round_number

    if round_number % 3 == 0 then -- chance of special round every 3 rounds
        -- special rounds have unique agent profiles to spice things up
        if math.random(1, 100) <= SpawnManager.special_round_chance then
            -- TODO: consider making this a data member on the wave delegator class instead
            local is_survive_until = math.random(1, 100) <= SpawnManager.survive_until_chance_on_special_round
            local wave_type_enum = is_survive_until and WaveTypeEnum.SurviveUntil or WaveTypeEnum.Quota

            local random_special_wave_delegator_class = random_weighted_table_value({
                [RobotWaveDelegator] = 100,
                [VampireWolfWaveDelegator] = 100,
                [UndeadWaveDelegator] = 100
            })
            self.survive_until_time = random_special_wave_delegator_class.survive_until_time
            self.delegator = random_special_wave_delegator_class(wave_type_enum, round_data)
            self.delegator_class = random_special_wave_delegator_class
        end
    elseif round_number % 5 == 0 and round_number >= 10 then -- chance of boss round every 5 rounds
        -- boss waves cannot be survive-until
        if math.random(1, 100) <= SpawnManager.boss_round_chance then
            local random_special_boss_wave_delegator_class = random_weighted_table_value({
                [RobotWaveDelegator] = 50
            })
            self.delegator = random_special_boss_wave_delegator_class(WaveTypeEnum.Boss, round_data)
            self.delegator_class = random_special_boss_wave_delegator_class
        end
    end

    -- if not a special round, then it's a BasicEnemy round
    if not self.delegator then
        local is_survive_until = math.random(1, 100) <= SpawnManager.survive_until_chance_on_normal_round
        local wave_type_enum = is_survive_until and WaveTypeEnum.SurviveUntil or WaveTypeEnum.Quota
        self.survive_until_time = BasicEnemyWaveDelegator.survive_until_time
        self.delegator = BasicEnemyWaveDelegator(wave_type_enum, round_data)
        self.delegator_class = BasicEnemyWaveDelegator

        -- chance of single-weapon type round
        local is_single_weapon_type = math.random(1, 100) <= SpawnManager.single_weapon_round_chance
        if is_single_weapon_type then
            local weapon_type_enum = EnemyWeapons:GetRandomSingleWeaponType()
            self.delegator:SetSingleWeaponType(weapon_type_enum)
        end
    end
end

function SpawnManager:NewRound(round_number, difficulty, number_of_players)
    local round_data = {
        round_number = round_number,
        difficulty = difficulty,
        number_of_players = number_of_players
    }

    SpawnManager:StopDelegator()
    SpawnManager:GenerateWave(round_data) -- assigns a delegator and picks the wave type
    self.delegator:SetActive(true)

    print("Round #" .. tostring(round_number))
    print(self.delegator)
    Chat:Broadcast({text = tostring(self.delegator)})

    -- spawn friendles if not enough players
    --self:SpawnFriendliesIfNecessary(round_number, difficulty, number_of_players)
end

function SpawnManager:StopDelegator()
    if self.delegator then
        self.delegator:SetActive(false)
    end
    self.delegator = nil
end

function SpawnManager:GameEnd(args)
    SpawnManager:StopDelegator()
end

function SpawnManager:SpawnFriendliesIfNecessary(round_number, difficulty, number_of_players)
    -- self.friendly_delegator = FriendliesDelegator() ???
end

--[[
function SpawnManager:DelegateFriendlySpawn(alive_players)
    local found = false
    local attempts = 0

    while (attempts < 10) do
        local random_alive_player = random_table_value(alive_players)
        if not random_alive_player:GetValue("Downed") then
            local random_friendly_agent_profile_enum = SpawnManager:GetRandomInactiveFriendlyProfile()

            if random_friendly_agent_profile_enum then
                print(random_alive_player, " chosen for Friendly Spawn delegation")

                Network:Send("gameplay/DelegateActorSpawn", random_alive_player:GetId(), {
                    spawn_strategy_enum = SpawnStrategyEnum.LocalPlayerPosition,
                    delegation_data = {
                        agent_profile_enum = random_friendly_agent_profile_enum,
                        actor_group_enum = ActorGroupEnum.PlayerGroup
                    }
                })
            end

            break
        end

        attempts = attempts + 1
    end
end
]]

function SpawnManager:SpawnActor(args)
    print("Actor Spawn requested by: " , args.player)
    local spawn_position = vector3(args.x, args.y, args.z)
    local delegation_data = args.delegation_data

    ActorManager:Spawn(
        args.player, 
        delegation_data.agent_profile_enum,
        delegation_data.actor_group_enum,
        {
            spawn_position = spawn_position,
            weapon = args.delegation_data.weapon_enum
        }
    )
end

-- adjust for players quitting
function SpawnManager:PlayerQuit(args)
    if not GameManager:GetIsGameInProgress() then return end

    self.delegator:PlayerQuit(args)
end

function SpawnManager:ActorKilled(args)
    if not GameManager:GetIsGameInProgress() then return end

    self.delegator:ActorKilled(args)
end

SpawnManager = SpawnManager()