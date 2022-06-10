--[[              "RAIN",
                "FOG",
                "SNOWLIGHT",
                "THUNDER",
                "BLIZZARD",
                "SNOW",
                "MISTY",
                "SUNNY",
                "HIGHPRESSURE",
                "CLEARING",
                "SLEET",
                "DRIZZLE",
                "SHOWER",
                "SNOWCLEARING",
                "OVERCASTDARK",
                "THUNDERSTORM",
                "SANDSTORM",
                "HURRICANE",
                "HAIL",
                "WHITEOUT",
                "GROUNDBLIZZARD",
            ]]

if IsTest then

    -- you type in 'z' in the server console or client console
    RegisterCommand("z",
        function(source, args, rawCommand)
            --local actor = Zombie()
            --actor:SetNetId(34)
            --print("Actor net id: ", actor:GetNetId())
            --print("tostring returns: " .. tostring(actor))
            --print("tostring returns: " .. tostring(actor))
            print(1 ~ 5)
        end,
        false
    )

    RegisterCommand("val",
        function(source, args, rawCommand)
            LobbyManager:ChatCommand({text = "/val"})
        end,
        false
    )

    AddEventHandler("chatMessage", function(player_id, playerName, message)
        --local player = Player(playerId)

        --if message == "test" then
        --print("playerName: " .. playerName) -- Dev_34
        --print("playerId: " .. type(playerId)) -- a number
            
            --local playerPed = GetPlayerPed(player) -- returns a number (must be ID)
            --print("playerPed: " .. tostring(playerPed))
            --print("playerId type: " .. type(playerId) .. " with value " .. tostring(playerId))
            --local x, y, z = GetEntityCoords(playerPed)

            --print(tostring(player:GetPosition()))
            --local x, y, z = player:GetPositionXYZ()
            --print(tostring(x))
            --print(tostring(y))
            --print(tostring(z))

            --local zombie = Zombie()
            --zombie:Spawn(x, y, z)

            --local players = GetPlayers()
            --for k, v in pairs(players) do
            --    print(k, v)
            --end
        --end
        if message == "/tome" then
            TriggerClientEvent("TOME", -1, player_id)
        end
    end)
end

DevsTests = class()

function DevsTests:__init()
    Events:Subscribe("ChatMessage", function(args)
        local words = split(args.text, " ")

        if words[1] == "weather" then
            World:SetWorldWeather(Weathers[tonumber(words[2])])
            World:SetTime(12, 12, 0)
        end
    end)




    Network:Subscribe("ai/RequestFriendly", function(args)
        if not args.num then
            ActorManager:Spawn(
                args.player, 
                ActorTypeEnum.BasicFriendly, 
                ActorGroupEnum.PlayerGroup,
                {
                    spawn_position = vector3(args.x, args.y, args.z)
                }
            )
        else
            for i = 1, tonumber(args.num) do
                local new_pos = vector3(args.x + .3, args.y + .3, args.z)

                ActorManager:Spawn(
                    args.player, 
                    ActorTypeEnum.BasicFriendly, 
                    ActorGroupEnum.PlayerGroup,
                    {
                        spawn_position = new_pos
                    }
                )
            end
        end
    end)

    Network:Subscribe("ai/AgentTest", function(args)
        ActorManager:Spawn(
            args.player, 
            AgentProfileEnum.RobotBoss,
            ActorGroupEnum.EnemyGroup,
            {
                spawn_position = vector3(args.x, args.y, args.z)
            }
        )
    end)
end

if IsTest then
    DevsTests = DevsTests()
end