test = class()
-- connect 158.69.59.135:30121

function test:__init()

    RegisterCommand("tp", function(source, args, rawCommand)
        LocalPlayer:SetPosition(vector3(tonumber(args[1]), tonumber(args[2]), tonumber(args[3])))
    end)

    RegisterCommand("testnative", function(source, args, rawCommand)
        print(SetPedSuffersCriticalHits)
    end)

    RegisterCommand("netvals", function(source, args, rawCommand)
        local p = LocalPlayer:GetPlayer()
        print("Alive: ", p:GetValue("Alive"))
        print("Downed: ", p:GetValue("Downed"))
        print("InGame: ", p:GetValue("InGame"))
        print("Spectate: ", p:GetValue("Spectate"))
    end)

    RegisterCommand("nextround", function(source, args, rawCommand)
        Network:Send("NextRound")
    end)

    RegisterCommand("who", function(source, args, rawCommand)
        for id, player in pairs(cPlayers:GetPlayers()) do
            if not LocalPlayer:IsPlayer(player) then
                print("going to spectate player: ", player)
                print("InGame: ", player:GetValue("InGame"))
            end
        end
    end)

    RegisterCommand("myhealth", function(source, args, rawCommand)
        Citizen.CreateThread(function()
            while true do
                Wait(1000)
                print("Localplayer Health: ", GetEntityHealth(LocalPlayer:GetPedId()))
            end
        end)
    end)

    RegisterCommand("invin", function(source, args, rawCommand)
        SetEntityInvincible(LocalPlayer:GetPedId(), true)
    end)

    RegisterCommand("down", function(source, args, rawCommand)
        LocalPlayer.behaviors.DownedLocalPlayerBehavior.downed = not LocalPlayer.behaviors.DownedLocalPlayerBehavior.downed
        
        if LocalPlayer.behaviors.DownedLocalPlayerBehavior.downed == false then
            SetPedCanRagdoll(LocalPlayer:GetPedId(), false)
        end
    end)

    RegisterCommand("attack", function(source, args, rawCommand)
        for id, actor in pairs(ActorManager.actors) do
            ClearPedTasks(actor:GetPedId())
            RegisterHatedTargetsAroundPed(actor:GetPedId(), 350.0)
            TaskCombatHatedTargetsAroundPed(actor:GetPedId(), 350.0, 0)
        end
    end)

    RegisterCommand("combatfloats", function(source, args, rawCommand)
        local num = tonumber(args[1])
        print("num: {", num, "}")

        for id, actor in pairs(ActorManager.actors) do
            local combat_float = GetCombatFloat(actor:GetPedId(), num)
            print("combat_float: ", combat_float)
        end
    end)

    RegisterCommand("combatability", function(source, args, rawCommand)
        local num = tonumber(args[1])
        print("num: {", num, "}")

        for id, actor in pairs(ActorManager.actors) do
            SetPedCombatAbility(actor:GetPedId(), num)
            --[[
                from FiveM:
                0: CA_Poor  
                1: CA_Average  
                2: CA_Professional  
            ]]
        end
    end)

    RegisterCommand("combatattributes", function(source, args, rawCommand)
        local num = tonumber(args[1])
        print("num: {", num, "}")

        for id, actor in pairs(ActorManager.actors) do
            SetPedCombatAttributes(actor:GetPedId(), num, false)
            --SetPedCombatAttributes(actor:GetPedId(), 0, false) -- stops the ped from using any cover. ped just runs and shoots at players
            --[[
                from FiveM:
                0: CA_Poor  
                1: CA_Average  
                2: CA_Professional  
            ]]
        end
    end)
    
    RegisterCommand("friendly", function(source, args, rawCommand)
        local x,y,z = LocalPlayer:GetPositionXYZ()
        Network:Send("ai/RequestFriendly", {x = x, y = y, z = z, num = tonumber(args[1])})
    end)

    RegisterCommand("agent", function(source, args, rawCommand)
        local x,y,z = LocalPlayer:GetPositionXYZ()
        Network:Send("ai/AgentTest", {x = x, y = y, z = z, num = tonumber(args[1])})
    end)

    RegisterCommand("groups", function(source, args, rawCommand)
        for id, actor in pairs(ActorManager.actors) do
            print("Actor group: ", ActorGroupEnum:GetFromHash(GetPedRelationshipGroupHash(actor:GetPedId())))

            print("Actor relationship to LocalPlayer: ", GetRelationshipBetweenPeds(actor:GetPedId(), LocalPlayer:GetPedId()))
        end

        print("LocalPlayer group: ", LocalPlayer:GetActorGroupEnum())


    end)

    RegisterCommand("deleteped", function(source, args, rawCommand)
        for id, actor in pairs(ActorManager.actors) do
            print(IsEntityAPed(actor:GetPedId()))
            DeleteEntity(actor:GetPedId())
        end
    end)

    self.poses = {}
    RegisterCommand("sp", function(source, args, rawCommand)
        table.insert(self.poses, {
            pos = LocalPlayer:GetPosition(),
            heading = LocalPlayer:GetEntity():GetYaw()
        })

        for k, v in pairs(self.poses) do
            local x, y, z = v.pos.x, v.pos.y, v.pos.z
            local heading = v.heading
            print('{"pos": {"x": ' .. tostring(x) .. ', "y": ' .. tostring(y) .. ', "z": ' .. tostring(z) .. '},"heading": ' .. tostring(heading) .. '}')
        end
    end)
    RegisterCommand("splist", function(source, args, rawCommand)
        for k, v in pairs(self.poses) do
            local x, y, z = v.pos.x, v.pos.y, v.pos.z
            local heading = v.heading
            print('{"pos": {"x": ' .. tostring(x) .. ', "y": ' .. tostring(y) .. ', "z": ' .. tostring(z) .. '},"heading": ' .. tostring(heading) .. '}')
        end
    end)

    RegisterCommand("ragdoll", function(source, args, rawCommand)
        Citizen.CreateThread(function()
            for i = 1, 1000 do
                Wait(350)
                SetPedToRagdoll(LocalPlayer:GetPedId(), -1, -1, 0, 0, 0, 0)
            end
        end)
    end)

    RegisterCommand("spectate", function(source, args, rawCommand)
        SpectateMode:Enable(10)
    end)

    RegisterCommand("stopspectate", function(source, args, rawCommand)
        SpectateMode:StopSpectating({respawn = true})
    end)

    RegisterCommand("randomweapon", function(source, args, rawCommand)
        local localplayer_ped = LocalPlayer:GetPed()
        local ped_id = localplayer_ped.ped_id

        -- giving weapons to peds
        -- GiveWeaponToPed(ped_id, hash, ammo, isHidden, equipNow)
        print(WeaponEnum:GetRandomWeaponEnum())
        local hash = WeaponEnum:GetWeaponHash(WeaponEnum:GetRandomWeaponEnum())
        GiveWeaponToPed_2(ped_id, hash, 100, false, 1, false, 0.0)
    end)

    RegisterCommand("pos", function(source, args, rawCommand)
        print(LocalPlayer:GetPosition())

        local x,y,z = LocalPlayer:GetPositionXYZ()

        --print('"pos": {"x": ' .. tostring(x) .. ', "y": ' .. tostring(y) .. ', "z": ' .. tostring(z) .. '},')
        --print('"heading":', GetEntityHeading(LocalPlayer:GetPedId()))

        print('{"pos": {"x": ' .. tostring(x) .. ', "y": ' .. tostring(y) .. ', "z": ' .. tostring(z) .. '}},')
    end)

    RegisterCommand("test", function(source, args, rawCommand)
        local x, y, z = LocalPlayer:GetPositionXYZ()
        TriggerServerEvent("ai/Test", {x = x, y = y, z = z, num = tonumber(args[1])})
    end)

    RegisterCommand("spawn", function(source, args, rawCommand)
        LocalPlayer:Spawn({
            pos = vector3(-302.01, 789.1, 118.0),
            model = "Player_Zero"
        })
    end)

    RegisterCommand("gun", function(source, args, rawCommand)
        local localplayer_ped = LocalPlayer:GetPed()
        local ped_id = localplayer_ped.ped_id

        -- giving weapons to peds
        -- GiveWeaponToPed(ped_id, hash, ammo, isHidden, equipNow)

        local hash = WeaponEnum:GetWeaponHash(WeaponEnum.ShotgunSawedoff)
        GiveWeaponToPed_2(ped_id, hash, 100, false, 1, false, 0.0)

        local hash = WeaponEnum:GetWeaponHash(WeaponEnum.BrokenSword)
        GiveWeaponToPed_2(ped_id, hash, 100, false, 1, false, 0.0)

        local hash = WeaponEnum:GetWeaponHash(WeaponEnum.Dynamite)
        GiveWeaponToPed_2(ped_id, hash, 100, false, 1, false, 0.0)
    end)

    

    RegisterCommand("sniper", function(source, args, rawCommand)
        local localplayer_ped = LocalPlayer:GetPed()
        local ped_id = localplayer_ped.ped_id

        -- giving weapons to peds
        -- GiveWeaponToPed(ped_id, hash, ammo, isHidden, equipNow)
        local hash = WeaponEnum:GetWeaponHash(WeaponEnum.ShotgunPump)
        GiveWeaponToPed_2(ped_id, hash, 100, false, 1, false, 0.0)
    end)

    RegisterCommand("ammos", function(source, args, rawCommand)
        for unique_id, player in pairs(cPlayers:GetPlayers()) do
            local ped = player:GetPedId()

            print("ped id: ", ped)
        end
    end)

    RegisterCommand("control", function(source, args, rawCommand)

        Citizen.CreateThread(function()
            while true do
                if 1==1 then break end
                Wait(20)
                for actor_unique_id, actor in pairs(ActorManager.actors) do
                    SetEntityAsNoLongerNeeded(actor:GetPedId())
                    --SetPedAsNoLongerNeeded(actor:GetPedId())
                    DeletePed(actor:GetPedId())
                    NetworkRequestControlOfNetworkId(actor.net_id)

                    if actor:GetLocalPlayerHosted() and NetworkHasControlOfNetworkId(actor.net_id) then
                        SetEntityAsNoLongerNeeded(actor:GetPedId())
                        Chat:Debug("HAS CONTROL - TELL DEV")
                    end
                end
            end
        end)
    end)


    Events:Subscribe("LocalPlayerChat", function(args)
        local words = split(args.text, " ")
        
        if words[1] == "/test" then
            local num = tonumber(words[2])

            local x, y, z = LocalPlayer:GetPositionXYZ()
            Citizen.Trace("x: " .. tostring(x))
            Citizen.Trace("y: " .. tostring(y))
            Citizen.Trace("z: " .. tostring(z))
            TriggerServerEvent("ai/Test", {x = x, y = y, z = z, num = num})
        end

        if words[1] == "/seed" then
            local seed1 = math.randomseed("test")
            print(math.random(1, 5))
            local seed2 = math.randomseed("test")
            print(math.random(1, 5))
        end

        -- Hit detection / damage / Weapons testing
        if words[1] == "/gun" then
            local localplayer_ped = LocalPlayer:GetPed()
            local ped_id = localplayer_ped.ped_id

            -- giving weapons to peds
            -- GiveWeaponToPed(ped_id, hash, ammo, isHidden, equipNow)
            local hash = WeaponEnum:GetWeaponHash(WeaponEnum.RepeaterHenry)
            GiveWeaponToPed(ped_id, hash, 100, false, 1, false, 0.0)

            -- need to use a SetPedAmmo after Giving Weapon, because using "/gun1" multiple times results in ammo increasing by 20 each time
        end

        if words[1] == "/gun2" then
            local localplayer_ped = LocalPlayer:GetPed()
            local ped_id = localplayer_ped.ped_id
            GiveWeaponToPed(ped_id, Weapon.AssaultRifle, 20, false, true)

        end

        if words[1] == "/invin" then
            LocalPlayer:SetTotallyInvincible(true)
        end

        if words[1] == "/obj" then
            local obj = Object({
                model = words[2],
                position = LocalPlayer:GetPosition(),
                callback = function(obj)
                    PlaceObjectOnGroundProperly(obj:GetEntity())
                end
            })
        end

        if words[1] == "/up" then
            LocalPlayer:SetPosition(LocalPlayer:GetPosition() + vector3(0,0,30))
        end

        if words[1] == "/pos" then
            print('"pos": {"x": ' .. tostring(x) .. ', "y": ' .. tostring(y) .. ', "z": ' .. tostring(z) .. '}')
        end

        if words[1] == "/veh" then
            local pos = LocalPlayer:GetPosition()
            LoadModel(VehicleEnum:GetVehicleHash(VehicleEnum.HorseBoat), function() 
                CreateVehicle(VehicleEnum:GetVehicleHash(VehicleEnum.HorseBoat), pos.x, pos.y, pos.z, 0, true, true, true, true)
            end)
        end

        if words[1] == "/money" then
            print("give money")
            SetPedMoney(LocalPlayer:GetPed():GetEntity(), 100)
        end

        if words[1] == "/removegun" then
            local localplayer_ped = LocalPlayer:GetPed()
            local ped_id = localplayer_ped.ped_id

            -- get the currently equipped weapon and remove it from the inventory
            --SetPedDropsInventoryWeapon(ped, weaponHash, xOffsetNumber, yOffsetNumber, zOffsetNumber, ammoCount)
            -- ^ is ammoCount == 0, do not create pick-up
            
            local _, ped_weapon_hash = GetCurrentPedWeapon(ped_id)
            --SetPedDropsInventoryWeapon(ped_id, ped_weapon_hash, 1, 0, 0, 5) -- drops the weapon as a pickup with 1 ammo
            RemoveWeaponFromPed(ped_id, ped_weapon_hash)
        end

        if words[1] == "/ammo" then
            local localplayer_ped = LocalPlayer:GetPed()
            local ped_id = localplayer_ped.ped_id

            -- get the current weapon
            local _, ped_weapon_hash = GetCurrentPedWeapon(ped_id)
            print("ped_weapon_hash: ", ped_weapon_hash) -- some big negative number or something

            --GetAmmoInPedWeapon(ped, weaponHash)
            -- gets the total ammo in the weapon (clip + reserve)
            local existing_ammo = GetAmmoInPedWeapon(ped_id, ped_weapon_hash)
            print("existing_ammo: ", existing_ammo)
            
            -- setting ped ammo to a certain value
            SetPedAmmo(ped_id, ped_weapon_hash, 5)
            -- there is also SetAmmoInClip(ped, weaponHash, ammo)
        end

        if words[1] == "/gunstats" then
            -- damage blablabla

        end

        if words[1] == "/getgundamage" then
           -- try modding the damage 
           -- could retrieve damage via native then multiply?
           local _, localplayer_weapon_hash = GetCurrentPedWeapon(LocalPlayer:GetPed().ped_id)
           local weapon_damage = GetWeaponDamage(localplayer_weapon_hash)


           print("weapon_damage: ", weapon_damage)
        end

        if words[1] == "/modgundamage" then
            --Citizen.CreateThread(function()
            --    local timer = Timer()

            --    while timer:GetMilliseconds() < 12000 do

            -- modifier is a float (0.0 -> inf) that *multiplies* the base damage of the weapon
            -- therefore, values under 1.0 will decrease weapon damage, and values over 1.0 will increase weapon damage
            -- 2.0 would double the weapon damage
            -- weapon damage can be retrieved via GetWeaponDamage. this native will also return updated damage amounts after SetWeaponDamageModifier has been used

            local _, localplayer_weapon_hash = GetCurrentPedWeapon(LocalPlayer:GetPed().ped_id)
            local current_weapon_damage = GetWeaponDamage(localplayer_weapon_hash)

            SetWeaponDamageModifier(localplayer_weapon_hash, 1.0)

            -- get the damage in the 

            -- noticed that even on 0.01 headshot with marksman pistol is still 1 shot kill, but body shots are weak.
            -- set all damage to 0.0 then detect when hits occur?
            -- setting damage to 0.0 does effectively stop all bullet damage

            --        Wait(1)
            --    end
            --end)
        end

    end)


    RegisterCommand("test2", 
        function(source, args, rawCommand)
            for _, clientPedId in ipairs(ActorManager:FindPedsInGame()) do
                print("Ped netId: ", PedToNet(clientPedId))
            end
        end
    )

    self.heading = 0

    RegisterCommand("turn", 
        function(source, args, rawCommand)
            for actor_unique_id, actor in pairs(ActorManager.actors) do
                local ped_instance = actor:GetPed()

                local animDict = "move_m@drunk@moderatedrunk"
                local animName = "wstop_l_90"
                --local animName = "idle_turn_l_90"

                ped_instance:PlayAnim({
                    animDict = animDict,
                    animName = animName
                })
            end
        end
    )

    RegisterCommand("s",
        function(source, args, rawCommand)
            for actor_unique_id, actor in pairs(ActorManager.actors) do
                local ped_instance = actor:GetPed()

                local animDict = "move_m@drunk@moderatedrunk"
                local animName = "wstop_l_90"
                --local animName = "idle_turn_l_90"

            end
        end


        -- TODO: find fastest distance method
        --[[

        local pos1 = vector3(3104.4234, 2270.7634, -8330.023)
        local pos2 = vector3(-2104.23, 6272.65345, 1348.0233)
        local dist

        local timer = Timer()
        for i = 1, 10000 do
            dist = Vector3Math:Distance(pos1, pos2)
            if dist < .03 then

            end
        end
        print("Method 1 time: ", timer:GetMilliseconds())
        ]]


    )

    RegisterCommand("cryptload", 
        function(source, args, rawCommand)
            --local code = assert(load("return 1 + 1"))
            --local num = code()
            --print("num: ", num) -- "num: 2"

            local plaintext = "HelloWorld"
            local encrypted = xor_cipher(plaintext)
            local decrypted = xor_cipher(encrypted)

            print("plaintext: ", plaintext)
            print("encrypted: ", encrypted)
            print("decrypted: ", decrypted)
        end
    )

    RegisterCommand("attack22", 
        function(source, args, rawCommand)
            for actor_unique_id, actor in pairs(ActorManager.actors) do
                local localplayer_ped = GetPlayerPed(PlayerId())
                local x, y, z = LocalPlayer:GetPositionXYZ()

                local ped_instance = actor:GetPed()

                local command_args = split(rawCommand, " ")
                local animation_dictionary = command_args[2]
                local animation_name = command_args[3]

                if count_table(command_args) == 3 then
                    ped_instance:PlayAnim({
                        animDict = animation_dictionary,
                        animName = animation_name
                    })
                end
            end


            if 1 == 1 then return end

            for actor_unique_id, actor in pairs(ActorManager.actors) do
                actor:EnsurePedAccess()
                actor:GoToEntityPermanently()
            end



















            Citizen.CreateThread(function()
                while true do
                Wait(400)

                local attack_speed = 2.0 -- 0.5 for zombie walk

                for actor_unique_id, actor in pairs(ActorManager.actors) do
                    actor:EnsurePedAccess()

                    local ped_id = actor.ped_id
                    local localplayer_ped = GetPlayerPed(PlayerId())
                    local localplayer_x, localplayer_y, localplayer_z = LocalPlayer:GetPositionXYZ()

                    local ped_instance = Ped({ped = ped_id})
                    local ped_pos = ped_instance:GetPosition()

                    -- #(vector3(0.0, 0.0, 0.0) - vector3(5.0, 5.0, 5.0))
                    local distance = #(vector3(localplayer_x, localplayer_z, localplayer_y) - vector3(ped_pos.x, ped_pos.z, ped_pos.y))
                    --print("distance: ", distance)
                    --print("punch_timer: ", actor.punch_timer:GetSeconds())

                    if distance < 1.5 and actor.punch_timer:GetSeconds() > 2.3 then
                        -- important TODO: test entity heading vs player position to see if we need to rotate
                        -- ensure ped rotation towards player
                        --local turn_time = 1000
                        --TaskTurnPedToFaceEntity(ped_id, localplayer_ped, turn_time) -- takes over 1.5s to turn completely. too slow to throw punches on-the-go
                        local angle_between = quat(LocalPlayer:GetPosition(), ped_instance:GetPosition())
                        print("Localplayer position: ", LocalPlayer:GetPosition())
                        print("Ped position: ", ped_instance:GetPosition())
                        print("angle_between: ", angle_between)
                        --SetEntityQuaternion(ped_id, angle_between.x, angle_between.y, angle_between.z, angle_between.w) -- no work atm
                        --SetEntityHeading(ped_id, self.heading) -- no work??
                        local entity = Entity(ped_id)
                        print("entity position: ", entity:GetPosition())
                        entity:SetEntityHeadingTowardsEntity(localplayer_ped)

                        Citizen.Wait(250)

                        -- throw the punch
                        ped_instance:PlayAnim({
                            --animDict = "melee@unarmed@streamed_variations", --punch #1
                            --animName = "plyr_takedown_front_slap",
                            animDict = "melee@unarmed@streamed_stealth", -- punch #4
                            animName = "plyr_stealth_kill_unarmed_hook_r",
                            position = ped_instance:GetPosition(),
                            animTime = 0.125
                        })

                        -- we need to turn the entity while they are punching or else they seem to miss badly?
                        -- ^ test

                        actor.punch_timer:Restart()
                        print("punched!!")
                        -- can use args.animTime to get parts of animations!
                    elseif actor.punch_timer:GetSeconds() > 2.3 then
                        TaskGoToEntity(ped_id, GetPlayerPed(PlayerId()), -1, 0.00001, attack_speed, 1073741824.0, 0)
                        SetPedKeepTask(ped_id, true)
                    end


                end
                end
            end)

            for actor_unique_id, actor in pairs(ActorManager.actors) do
                actor:EnsurePedAccess()
                local ped_id = actor.ped_id
                local localplayer_ped = GetPlayerPed(PlayerId())
                local x, y, z = LocalPlayer:GetPositionXYZ()

                local ped_instance = Ped({ped = ped_id})

                local command_args = split(rawCommand, " ")
                local animation_dictionary = command_args[2]
                local animation_name = command_args[3]

                if count_table(command_args) == 3 then
                    ped_instance:PlayAnim({
                        animDict = animation_dictionary,
                        animName = animation_name
                    })
                else
                    -- **** DECISION: this is the best way to make zombies keep chasing a player
                    -- doesnt do zombie / drug run at higher speed but does work pretty well, working configurable speed with lower speeds doing drunk walk!!!!
                    --- works with RottenVRemadeZombieConfig()
                    TaskGoToEntity(ped_id, GetPlayerPed(PlayerId()), -1, 0.00001, attack_speed, 1073741824.0, 0)
                    SetPedKeepTask(ped_id, true)
                end

                -- ** 'zombie standing ready for fight'  "melee@unarmed@streamed_background" => "idle"
                -- best punch (super short and fast): "melee@unarmed@streamed_variations" => "plyr_takedown_front_slap"
                -- weird drunk run might be good?: "move_f@drunk@a" => "run"

                -- short punch: "melee@unarmed@streamed_core_fps" => "short_0_punch"
                -- better short punch: "melee@unarmed@streamed_core_fps" => "light_finishing_punch"
                -- walk up a little bit then kick ground, then back up again: "melee@unarmed@streamed_core_fps" => "ground_attack_0"
                -- big hook punch w/ small walk-up: "melee@unarmed@streamed_stealth" => "plyr_stealth_kill_unarmed_hook_r"
                -- big punch (would have to cut the anim short somehow): "anim@melee@machete@streamed_core@" => "small_melee_wpn_short_range_0"
                -- machete attack (no machete, but could place staticobject weapon at hand) "anim@melee@machete@streamed_core@" => "small_melee_wpn_short_range_0"



                -- animal anims: CTRL-F for creatures@boar@move
                
                -- works for making large ped groups move toward a target without
                -- non-attackers lagging behind / ignoring the attack command
                -- 5t arg: speed, 1.0 appears to be walking speed while 2.0 appears to be max speed
                
                -- doesnt do the "drunk run" on the host, but does the drunk run on the other clients
                --TaskGoToCoordAnyMeans(ped_id, x, y, z, tofloat(1.5), 0, 0, 786603, tofloat(0))


                -- makes the ped melee attack / chase the player at running pace
                -- no zombie/drunk run
                --TaskPutPedDirectlyIntoMelee(ped_id, localplayer_ped, tofloat(0), tofloat(-1), tofloat(0), 0)


                -- works even from distance
                -- seems to last indefinitely
                -- only a couple of peds attack at one time
                --TaskCombatPed(ped_id, localplayer_ped, 0, 16)
            end

            --print("Entered attack command")
        end
    )

    Events:Subscribe("Render", function()
        if LocalPlayer:IsSpawned() then
            --local ped = LocalPlayer:GetPedId()
            --local pos = GetPedBoneCoords(ped, 31086, 0.3, 0.5, 0.15)
            --Render:DrawSphere(pos, .05, Colors.LawnGreen)
        end
    end)


    RegisterNetEvent('TOME')
    AddEventHandler("TOME", function(player_id) LocalPlayer:TeleportToPlayer(player_id) end)
end


if IsTest then
    test = test()
end

-- just to look at lol
all_ped_models = { "A_F_M_ARMCHOLERACORPSE_01",
"A_F_M_ARMTOWNFOLK_01",
"A_F_M_ArmTownfolk_02",
"A_F_M_AsbTownfolk_01",
"A_F_M_BiVFancyTravellers_01",
"A_F_M_BlWTownfolk_01",
"A_F_M_BlWTownfolk_02",
"A_F_M_BlWUpperClass_01",
"A_F_M_BtcHillbilly_01",
"A_F_M_BTCObeseWomen_01",
"A_F_M_BynFancyTravellers_01",
"A_F_M_FAMILYTRAVELERS_COOL_01","A_F_M_FAMILYTRAVELERS_WARM_01","A_F_M_GaMHighSociety_01",
"A_F_M_GriFancyTravellers_01","A_F_M_GuaTownfolk_01","A_F_M_HtlFancyTravellers_01","A_F_M_LagTownfolk_01",
"A_F_M_LowerSDTownfolk_01","A_F_M_LowerSDTownfolk_02","A_F_M_LowerSDTownfolk_03",
"A_F_M_LOWERTRAINPASSENGERS_01","A_F_M_MiddleSDTownfolk_01",
"A_F_M_MiddleSDTownfolk_02","A_F_M_MiddleSDTownfolk_03","A_F_M_MIDDLETRAINPASSENGERS_01",
"A_F_M_NbxSlums_01","A_F_M_NbxUpperClass_01","A_F_M_NbxWhore_01","A_F_M_RhdProstitute_01",
"A_F_M_RhdTownfolk_01","A_F_M_RhdTownfolk_02","A_F_M_RhdUpperClass_01","A_F_M_RkrFancyTravellers_01",
"A_F_M_ROUGHTRAVELLERS_01","A_F_M_SclFancyTravellers_01","A_F_M_SDChinatown_01",
"A_F_M_SDFancyWhore_01","A_F_M_SDObeseWomen_01","A_F_M_SDSERVERSFORMAL_01",
"A_F_M_SDSlums_02","A_F_M_SKPPRISONONLINE_01","A_F_M_StrTownfolk_01","A_F_M_TumTownfolk_01",
"A_F_M_TumTownfolk_02","A_F_M_UniCorpse_01","A_F_M_UPPERTRAINPASSENGERS_01",
"A_F_M_ValProstitute_01","A_F_M_ValTownfolk_01","A_F_M_VhtProstitute_01",
"A_F_M_VhtTownfolk_01","A_F_M_WapTownfolk_01","A_F_O_BlWUpperClass_01",
"A_F_O_BtcHillbilly_01","A_F_O_GuaTownfolk_01","A_F_O_LagTownfolk_01",
"A_F_O_SDChinatown_01","A_F_O_SDUpperClass_01","A_F_O_WAPTOWNFOLK_01",
"A_M_M_ARMCHOLERACORPSE_01","A_M_M_ARMDEPUTYRESIDENT_01","A_M_M_ARMTOWNFOLK_01",
"A_M_M_armTOWNFOLK_02","A_M_M_ASBBOATCREW_01","A_M_M_ASBDEPUTYRESIDENT_01",
"A_M_M_AsbMiner_01","A_M_M_ASBMINER_02","A_M_M_ASBMINER_03","A_M_M_asbminer_04",
"A_M_M_AsbTownfolk_01","A_M_M_ASBTOWNFOLK_01_LABORER","A_M_M_BiVFancyDRIVERS_01",
"A_M_M_BiVFancyTravellers_01","A_M_M_BiVRoughTravellers_01","A_M_M_BiVWorker_01",
"A_M_M_BlWForeman_01","A_M_M_BlWLaborer_01","A_M_M_BlWLaborer_02","A_M_M_BLWObeseMen_01",
"A_M_M_BlWTownfolk_01","A_M_M_BlWUpperClass_01","A_M_M_BtcHillbilly_01",
"A_M_M_BTCObeseMen_01","A_M_M_BynFancyDRIVERS_01","A_M_M_BynFancyTravellers_01",
"A_M_M_BynRoughTravellers_01","A_M_M_BynSurvivalist_01","A_M_M_CARDGAMEPLAYERS_01",
"A_M_M_CHELONIAN_01","A_M_M_DELIVERYTRAVELERS_COOL_01","A_M_M_deliverytravelers_warm_01",
"A_M_M_DOMINOESPLAYERS_01","A_M_M_EmRFarmHand_01","A_M_M_FAMILYTRAVELERS_COOL_01",
"A_M_M_FAMILYTRAVELERS_WARM_01","A_M_M_FARMTRAVELERS_COOL_01","A_M_M_FARMTRAVELERS_WARM_01",
"A_M_M_FiveFingerFilletPlayers_01","A_M_M_FOREMAN","A_M_M_GaMHighSociety_01",
"A_M_M_GRIFANCYDRIVERS_01","A_M_M_GriFancyTravellers_01","A_M_M_GriRoughTravellers_01",
"A_M_M_GriSurvivalist_01","A_M_M_GuaTownfolk_01","A_M_M_HtlFancyDRIVERS_01",
"A_M_M_HtlFancyTravellers_01","A_M_M_HtlRoughTravellers_01","A_M_M_HtlSurvivalist_01",
"A_M_M_huntertravelers_cool_01","A_M_M_HUNTERTRAVELERS_WARM_01","A_M_M_JamesonGuard_01",
"A_M_M_LagTownfolk_01","A_M_M_LowerSDTownfolk_01","A_M_M_LowerSDTownfolk_02",
"A_M_M_LOWERTRAINPASSENGERS_01","A_M_M_MiddleSDTownfolk_01","A_M_M_MiddleSDTownfolk_02",
"A_M_M_MiddleSDTownfolk_03","A_M_M_MIDDLETRAINPASSENGERS_01","A_M_M_MOONSHINERS_01",
"A_M_M_NbxDockWorkers_01","A_M_M_NbxLaborers_01","A_M_M_NbxSlums_01","A_M_M_NbxUpperClass_01",
"A_M_M_NEAROUGHTRAVELLERS_01","A_M_M_RANCHER_01","A_M_M_RANCHERTRAVELERS_COOL_01",
"A_M_M_RANCHERTRAVELERS_WARM_01","A_M_M_RHDDEPUTYRESIDENT_01","A_M_M_RhdForeman_01",
"A_M_M_RHDObeseMen_01","A_M_M_RhdTownfolk_01","A_M_M_RHDTOWNFOLK_01_LABORER","A_M_M_RhdTownfolk_02",
"A_M_M_RhdUpperClass_01","A_M_M_RkrFancyDRIVERS_01","A_M_M_RkrFancyTravellers_01",
"A_M_M_RkrRoughTravellers_01","A_M_M_RkrSurvivalist_01","A_M_M_SclFancyDRIVERS_01","A_M_M_SclFancyTravellers_01",
"A_M_M_SclRoughTravellers_01","A_M_M_SDChinatown_01","A_M_M_SDDockForeman_01","A_M_M_SDDockWorkers_02",
"A_M_M_SDFANCYTRAVELLERS_01","A_M_M_SDLaborers_02","A_M_M_SDObesemen_01","A_M_M_SDROUGHTRAVELLERS_01","A_M_M_SDSERVERSFORMAL_01",
"A_M_M_SDSlums_02","A_M_M_SkpPrisoner_01","A_M_M_SkpPrisonLine_01","A_M_M_SmHThug_01","A_M_M_STRDEPUTYRESIDENT_01",
"A_M_M_STRFANCYTOURIST_01","A_M_M_StrLaborer_01","A_M_M_StrTownfolk_01","A_M_M_TumTownfolk_01","A_M_M_TumTownfolk_02",
"A_M_M_UniBoatCrew_01","A_M_M_UniCoachGuards_01","A_M_M_UniCorpse_01","A_M_M_UniGunslinger_01","A_M_M_UPPERTRAINPASSENGERS_01",
"A_M_M_VALCRIMINALS_01","A_M_M_VALDEPUTYRESIDENT_01","A_M_M_ValFarmer_01","A_M_M_ValLaborer_01","A_M_M_ValTownfolk_01",
"A_M_M_ValTownfolk_02","A_M_M_VHTBOATCREW_01","A_M_M_VhtThug_01","A_M_M_VhtTownfolk_01","A_M_M_WapWarriors_01",
"A_M_O_BlWUpperClass_01","A_M_O_BtcHillbilly_01","A_M_O_GuaTownfolk_01","A_M_O_LagTownfolk_01","A_M_O_SDChinatown_01",
"A_M_O_SDUpperClass_01","A_M_O_WAPTOWNFOLK_01","A_M_Y_AsbMiner_01","A_M_Y_AsbMiner_02","A_M_Y_ASBMINER_03",
"A_M_Y_ASBMINER_04","A_M_Y_NbxStreetKids_01","A_M_Y_NbxStreetKids_Slums_01","A_M_Y_SDStreetKids_Slums_02",
"A_M_Y_UniCorpse_01","CS_abe","CS_AberdeenPigFarmer","CS_AberdeenSister","CS_abigailroberts","CS_Acrobat",
"CS_adamgray","CS_AgnesDowd","CS_albertcakeesquire","CS_albertmason","CS_AndersHelgerson","CS_ANGEL",
"CS_angryhusband","CS_angusgeddes","CS_ansel_atherton","CS_ANTONYFOREMEN","CS_archerfordham","CS_archibaldjameson",
"CS_ArchieDown","CS_ARTAPPRAISER","CS_ASBDEPUTY_01","CS_ASHTON","CS_balloonoperator","CS_bandbassist",
"CS_banddrummer","CS_bandpianist","CS_bandsinger","CS_baptiste","CS_bartholomewbraithwaite",
"CS_BATHINGLADIES_01","CS_BeatenUpCaptain","CS_beaugray","CS_billwilliamson","CS_BivCoachDriver",
"CS_BLWPHOTOGRAPHER","CS_BLWWITNESS","CS_braithwaitebutler","CS_braithwaitemaid","CS_braithwaiteservant",
"CS_brendacrawley","CS_bronte","CS_BrontesButler","CS_brotherdorkins","CS_brynntildon","CS_Bubba",
"CS_CABARETMC","CS_CAJUN","CS_cancan_01","CS_cancan_02","CS_cancan_03","CS_cancan_04","CS_CanCanMan_01",
"CS_captainmonroe","CS_Cassidy","CS_catherinebraithwaite","CS_cattlerustler","CS_CAVEHERMIT","CS_chainprisoner_01",
"CS_chainprisoner_02","CS_charlessmith","CS_ChelonianMaster","CS_CIGCARDGUY","CS_clay","CS_CLEET",
"CS_clive","CS_colfavours","CS_ColmODriscoll","CS_COOPER","CS_CornwallTrainConductor","CS_crackpotinventor",
"CS_crackpotRobot","CS_creepyoldlady","CS_creolecaptain","CS_creoledoctor","CS_creoleguy","CS_dalemaroney",
"CS_DaveyCallender","CS_davidgeddes","CS_DESMOND","CS_DIDSBURY","CS_DinoBonesLady","CS_DisguisedDuster_01",
"CS_DisguisedDuster_02","CS_DisguisedDuster_03","CS_DOROETHEAWICKLOW","CS_DrHiggins","CS_DrMalcolmMacIntosh",
"CS_duncangeddes","CS_DusterInformant_01","CS_dutch","CS_EagleFlies","CS_edgarross","CS_EDITH_JOHN","CS_EdithDown",
"CS_edmundlowry","CS_EscapeArtist","CS_EscapeArtistAssistant","CS_evelynmiller","CS_EXCONFEDINFORMANT",
"CS_exconfedsleader_01","CS_EXOTICCOLLECTOR","CS_famousgunslinger_01","CS_famousgunslinger_02","CS_famousgunslinger_03",
"CS_famousgunslinger_04","CS_FamousGunslinger_05","CS_FamousGunslinger_06","CS_FEATHERSTONCHAMBERS",
"CS_FeatsOfStrength","CS_FIGHTREF","CS_Fire_Breather","CS_FISHCOLLECTOR","CS_forgivenhusband_01","CS_forgivenwife_01",
"CS_FORMYARTBIGWOMAN","CS_FRANCIS_SINCLAIR","CS_frenchartist","CS_FRENCHMAN_01","CS_fussar",
"CS_garethbraithwaite","CS_GAVIN","CS_genstoryfemale","CS_genstorymale","CS_geraldbraithwaite","CS_GermanDaughter",
"CS_GermanFather","CS_GermanMother","CS_GermanSon","CS_GILBERTKNIGHTLY","CS_GLORIA","CS_GrizzledJon","CS_GuidoMartelli","CS_HAMISH",
"CS_hectorfellowes","CS_henrilemiux","CS_HERBALIST","CS_hercule","CS_HestonJameson","CS_hobartcrawley","CS_hoseamatthews","CS_IANGRAY",
"CS_jackmarston","CS_jackmarston_teen","CS_JAMIE","CS_JANSON","CS_javierescuella","CS_Jeb","CS_jimcalloway","CS_jockgray","CS_JOE",
"CS_JoeButler","CS_johnmarston","CS_JOHNTHEBAPTISINGMADMAN","CS_JohnWeathers","CS_josiahtrelawny","CS_Jules","CS_karen","CS_KarensJohn_01",
"CS_kieran","CS_LARAMIE","CS_leighgray","CS_LemiuxAssistant","CS_lenny","CS_leon","CS_leostrauss","CS_LeviSimon","CS_leviticuscornwall",
"CS_LillianPowell","CS_lillymillet","CS_LondonderrySon","CS_LUCANAPOLI","CS_Magnifico","CS_MAMAWATSON","CS_MARSHALL_THURWELL",
"CS_marybeth","CS_marylinton","CS_MEDITATINGMONK","CS_Meredith","CS_MeredithsMother","CS_MicahBell","CS_MicahsNemesis",
"CS_Mickey","CS_miltonandrews","CS_missMarjorie","CS_MIXEDRACEKID","CS_MOIRA","CS_mollyoshea","CS_mradler","CS_MRDEVON",
"CS_MRLINTON","CS_mrpearson","CS_Mrs_Calhoun","CS_MRS_SINCLAIR","CS_mrsadler","CS_MrsFellows","CS_mrsgeddes",
"CS_MrsLondonderry","CS_MrsWeathers","CS_MRWAYNE","CS_mud2bigguy","CS_MysteriousStranger","CS_NbxDrunk","CS_NbxExecuted",
"CS_NbxPoliceChiefFormal","CS_nbxreceptionist_01","CS_NIAL_WHELAN","CS_NicholasTimmins","CS_NILS","CS_NorrisForsythe",
"CS_obediahhinton","CS_oddfellowspinhead","CS_ODProstitute","CS_OPERASINGER","CS_PAYTAH","CS_penelopebraithwaite",
"CS_PinkertonGoon","CS_PoisonWellShaman","CS_POORJOE","CS_PRIEST_WEDDING","CS_PrincessIsabeau","CS_professorbell",
"CS_rainsfall","CS_RAMON_CORTEZ","CS_ReverendFortheringham","CS_revswanson","CS_rhodeputy_01","CS_RhoDeputy_02",
"CS_RhodesAssistant","CS_rhodeskidnapvictim","CS_rhodessaloonbouncer","CS_ringmaster","CS_ROCKYSEVEN_WIDOW","CS_samaritan",
"CS_SCOTTGRAY","CS_SD_STREETKID_01","CS_SD_STREETKID_01A","CS_SD_STREETKID_01B","CS_SD_STREETKID_02","CS_SDDoctor_01",
"CS_SDPRIEST","CS_SDSALOONDRUNK_01","CS_SDStreetKidThief","CS_sean","CS_SHERIFFFREEMAN","CS_SheriffOwens","CS_sistercalderon",
"CS_slavecatcher","CS_SOOTHSAYER","CS_strawberryoutlaw_01","CS_strawberryoutlaw_02","CS_strdeputy_01","CS_strdeputy_02",
"CS_strsheriff_01","CS_SUNWORSHIPPER","CS_susangrimshaw","CS_SwampFreak","CS_SWAMPWEIRDOSONNY","CS_SwordDancer","CS_tavishgray",
"CS_TAXIDERMIST","CS_theodorelevin","CS_thomasdown","CS_TigerHandler","CS_tilly","CS_TimothyDonahue","CS_TINYHERMIT",
"CS_tomdickens","CS_TownCrier","CS_TREASUREHUNTER","CS_twinbrother_01","CS_twinbrother_02","CS_twingroupie_01","CS_twingroupie_02",
"CS_uncle","CS_UNIDUSTERJAIL_01","CS_valauctionboss_01","CS_VALDEPUTY_01","CS_ValPrayingMan","CS_ValProstitute_01",
"CS_ValProstitute_02","CS_VALSHERIFF","CS_Vampire","CS_VHT_BATHGIRL","CS_WapitiBoy","CS_warvet","CS_WATSON_01","CS_WATSON_02",
"CS_WATSON_03","CS_WELSHFIGHTER","CS_WintonHolmes","CS_Wrobel","G_F_M_UNIDUSTER_01","G_M_M_BountyHunters_01",
"G_M_M_UniAfricanAmericanGang_01","G_M_M_UniBanditos_01","G_M_M_UniBraithwaites_01","G_M_M_UniBronteGoons_01",
"G_M_M_UniCornwallGoons_01","G_M_M_UniCriminals_01","G_M_M_UniCriminals_02","G_M_M_UniDuster_01","G_M_M_UniDuster_02",
"G_M_M_UniDuster_03","G_M_M_UniDuster_04","G_M_M_UNIDUSTER_05","G_M_M_UniGrays_01","G_M_M_UniGrays_02","G_M_M_UniInbred_01",
"G_M_M_UNILANGSTONBOYS_01","G_M_M_UNIMICAHGOONS_01","G_M_M_UniMountainMen_01","G_M_M_UniRanchers_01","G_M_M_UNISWAMP_01",
"MBH_RHODESRANCHER_FEMALES_0","MBH_RHODESRANCHER_TEENS_01","MBH_SKINNERSEARCH_MALES_01","MCCLELLAN_SADDLE_01","MES_ABIGAIL2_MALES_01",
"MES_FINALE2_FEMALES_01","MES_FINALE2_MALES_01","MES_FINALE3_MALES_01","MES_MARSTON1_MALES_01","MES_MARSTON2_MALES_01",
"MES_MARSTON5_2_MALES_01","MES_MARSTON6_FEMALES_01","MES_MARSTON6_MALES_01","MES_MARSTON6_TEENS_01","MES_SADIE4_MALES_01",
"MES_SADIE5_MALES_01","mp_female","mp_male","MSP_BOUNTYHUNTER1_FEMALES_01","MSP_BRAITHWAITES1_MALES_01","MSP_FEUD1_MALES_01",
"MSP_FUSSAR2_MALES_01","MSP_GANG2_MALES_01","MSP_GANG3_MALES_01","MSP_GRAYS1_MALES_01","MSP_GRAYS2_MALES_01","MSP_GUARMA2_MALES_01",
"MSP_INDUSTRY1_FEMALES_01","MSP_INDUSTRY1_MALES_01","MSP_INDUSTRY3_FEMALES_01","MSP_INDUSTRY3_MALES_01","MSP_MARY1_FEMALES_01",
"MSP_MARY1_MALES_01","MSP_MARY3_MALES_01","MSP_MOB0_MALES_01","MSP_MOB1_FEMALES_01","MSP_MOB1_MALES_01","MSP_MOB1_TEENS_01",
"MSP_MUDTOWN3_MALES_01","MSP_Mudtown3B_Females_01","MSP_Mudtown3B_Males_01","MSP_MUDTOWN5_MALES_01","MSP_NATIVE1_MALES_01",
"MSP_REVEREND1_MALES_01","MSP_SAINTDENIS1_FEMALES_01","MSP_SAINTDENIS1_MALES_01","MSP_SALOON1_FEMALES_01","MSP_SALOON1_MALES_01",
"MSP_SMUGGLER2_MALES_01","MSP_TRAINROBBERY2_MALES_01","MSP_TRELAWNY1_MALES_01","MSP_UTOPIA1_MALES_01","MSP_WINTER4_MALES_01",
"P_C_Horse_01","Player_Three","Player_Zero","RCES_ABIGAIL3_FEMALES_01","RCES_ABIGAIL3_MALES_01","RCES_BEECHERS1_MALES_01",
"RCES_EVELYNMILLER_MALES_01","RCSP_BEAUANDPENELOPE_MALES_01","RCSP_BEAUANDPENELOPE1_FEMALES_01","RCSP_CALDERON_MALES_01",
"RCSP_CALDERONSTAGE2_MALES_01","RCSP_CALDERONSTAGE2_TEENS_01","RCSP_CALLOWAY_MALES_01","RCSP_COACHROBBERY_MALES_01",
"RCSP_CRACKPOT_FEMALES_01","RCSP_CRACKPOT_MALES_01","RCSP_CREOLE_MALES_01","RCSP_DUTCH1_MALES_01","RCSP_DUTCH3_MALES_01",
"RCSP_EDITHDOWNES2_MALES_01","RCSP_FORMYART_FEMALES_01","RCSP_FORMYART_MALES_01","RCSP_GUNSLINGERDUEL4_MALES_01",
"RCSP_HEREKITTYKITTY_MALES_0","RCSP_HUNTING1_MALES_01","RCSP_MRMAYOR_MALES_01","RCSP_NATIVE_AMERICANFATHERS",
"RCSP_NATIVE1S2_MALES_01","RCSP_ODDFELLOWS_MALES_01","RCSP_ODRISCOLLS2_FEMALES_01","RCSP_POISONEDWELL_FEMALES_0",
"RCSP_POISONEDWELL_MALES_01","RCSP_POISONEDWELL_TEENS_01","RCSP_RIDETHELIGHTNING_FEMAL","RCSP_RIDETHELIGHTNING_MALES",
"RCSP_SADIE1_MALES_01","RCSP_SLAVECATCHER_MALES_01","RE_ANIMALATTACK_FEMALES_01","RE_ANIMALATTACK_MALES_01",
"RE_ANIMALMAULING_MALES_01","RE_APPROACH_MALES_01","RE_BEARTRAP_MALES_01","RE_BOATATTACK_MALES_01","RE_BURNINGBODIES_MALES_01",
"RE_CHECKPOINT_MALES_01","RE_COACHROBBERY_FEMALES_01","RE_COACHROBBERY_MALES_01","RE_CONSEQUENCE_MALES_01",
"RE_CORPSECART_FEMALES_01","RE_CORPSECART_MALES_01","RE_CRASHEDWAGON_MALES_01","RE_DARKALLEYAMBUSH_MALES_01","RE_DARKALLEYBUM_MALES_01",
"RE_DARKALLEYSTABBING_MALES_","RE_DEADBODIES_MALES_01","RE_DEADJOHN_FEMALES_01","RE_DEADJOHN_MALES_01","RE_DISABLEDBEGGAR_MALES_01",
"RE_DOMESTICDISPUTE_FEMALES_","RE_DOMESTICDISPUTE_MALES_01","RE_DROWNMURDER_FEMALES_01","RE_DROWNMURDER_MALES_01","RE_DRUNKCAMP_MALES_01",
"RE_DRUNKDUELER_MALES_01","RE_DUELBOASTER_MALES_01","RE_DUELWINNER_FEMALES_01","RE_DUELWINNER_MALES_01","RE_ESCORT_FEMALES_01",
"RE_EXECUTIONS_MALES_01","RE_FLEEINGFAMILY_FEMALES_01","RE_FLEEINGFAMILY_MALES_01","RE_FOOTROBBERY_MALES_01",
"RE_FRIENDLYOUTDOORSMAN_MALE","RE_FROZENTODEATH_FEMALES_01","RE_FROZENTODEATH_MALES_01","RE_FUNDRAISER_FEMALES_01",
"RE_FUSSARCHASE_MALES_01","RE_GOLDPANNER_MALES_01","RE_HORSERACE_FEMALES_01","RE_HORSERACE_MALES_01","RE_HOSTAGERESCUE_FEMALES_01",
"RE_HOSTAGERESCUE_MALES_01","RE_INBREDKIDNAP_FEMALES_01","RE_INBREDKIDNAP_MALES_01","RE_INJUREDRIDER_MALES_01",
"RE_KIDNAPPEDVICTIM_FEMALES_","RE_LARAMIEGANGRUSTLING_MALE","RE_LONEPRISONER_MALES_01","RE_LOSTDOG_DOGS_01",
"RE_LOSTDOG_TEENS_01","RE_LOSTDRUNK_FEMALES_01","RE_LOSTDRUNK_MALES_01","RE_LOSTFRIEND_MALES_01","RE_LOSTMAN_MALES_01",
"RE_MOONSHINECAMP_MALES_01","RE_MURDERCAMP_MALES_01","RE_MURDERSUICIDE_FEMALES_01","RE_MURDERSUICIDE_MALES_01",
"RE_NAKEDSWIMMER_MALES_01","RE_ONTHERUN_MALES_01","RE_OUTLAWLOOTER_MALES_01","RE_PARLORAMBUSH_MALES_01","RE_PEEPINGTOM_FEMALES_01",
"RE_PEEPINGTOM_MALES_01","RE_PICKPOCKET_MALES_01","RE_PISSPOT_FEMALES_01","RE_PISSPOT_MALES_01","RE_PLAYERCAMPSTRANGERS_FEMALES_01",
"RE_PLAYERCAMPSTRANGERS_MALES_01","RE_POISONED_MALES_01","RE_POLICECHASE_MALES_01","RE_PRISONWAGON_FEMALES_01",
"RE_PRISONWAGON_MALES_01","RE_PUBLICHANGING_FEMALES_01","RE_PUBLICHANGING_MALES_01","RE_PUBLICHANGING_TEENS_01","RE_RALLY_MALES_01",
"RE_RALLYDISPUTE_MALES_01","RE_RALLYSETUP_MALES_01","RE_RATINFESTATION_MALES_01","RE_ROWDYDRUNKS_MALES_01",
"RE_SAVAGEAFTERMATH_FEMALES_01","RE_SAVAGEAFTERMATH_MALES_01","RE_SAVAGEFIGHT_FEMALES_01","RE_SAVAGEFIGHT_MALES_01",
"RE_SAVAGEWAGON_FEMALES_01","RE_SAVAGEWAGON_MALES_01","RE_SAVAGEWARNING_MALES_01","RE_SHARPSHOOTER_MALES_01",
"RE_SHOWOFF_MALES_01","RE_SKIPPINGSTONES_MALES_01","RE_SKIPPINGSTONES_TEENS_01","RE_SLUMAMBUSH_FEMALES_01",
"RE_SNAKEBITE_MALES_01","RE_STALKINGHUNTER_MALES_01","RE_STRANDEDRIDER_MALES_01","RE_STREET_FIGHT_MALES_01",
"RE_TAUNTING_01","RE_TAUNTING_MALES_01","RE_TORTURINGCAPTIVE_MALES_0","RE_TOWNBURIAL_MALES_01","RE_TOWNCONFRONTATION_FEMALE",
"RE_TOWNCONFRONTATION_MALES_","RE_TOWNROBBERY_MALES_01","RE_TOWNWIDOW_FEMALES_01","RE_TRAINHOLDUP_FEMALES_01",
"RE_TRAINHOLDUP_MALES_01","RE_TRAPPEDWOMAN_FEMALES_01","RE_TREASUREHUNTER_MALES_01","RE_VOICE_FEMALES_01","RE_WAGONTHREAT_FEMALES_01",
"RE_WAGONTHREAT_MALES_01","RE_WASHEDASHORE_MALES_01","RE_WEALTHYCOUPLE_FEMALES_01","RE_WEALTHYCOUPLE_MALES_01",
"RE_WILDMAN_01","S_F_M_BwmWorker_01","S_F_M_CghWorker_01","S_F_M_MaPWorker_01","S_M_M_AmbientBlWPolice_01",
"S_M_M_AmbientLawRural_01","S_M_M_AmbientSDPolice_01","S_M_M_Army_01","S_M_M_ASBCowpoke_01","S_M_M_ASBDEALER_01",
"S_M_M_BankClerk_01","S_M_M_Barber_01","S_M_M_BLWCOWPOKE_01","S_M_M_BLWDEALER_01","S_M_M_BwmWorker_01","S_M_M_CghWorker_01",
"S_M_M_CKTWorker_01","S_M_M_COACHTAXIDRIVER_01","S_M_M_CornwallGuard_01","S_M_M_DispatchLawRural_01",
"S_M_M_DispatchLeaderPolice_01","S_M_M_DispatchLeaderRural_01","S_M_M_DispatchPolice_01","S_M_M_FussarHenchman_01",
"S_M_M_GENCONDUCTOR_01","S_M_M_HOFGuard_01","S_M_M_LiveryWorker_01","S_M_M_MAGICLANTERN_01","S_M_M_MaPWorker_01",
"S_M_M_MarketVendor_01","S_M_M_MARSHALLSRURAL_01","S_M_M_MicGuard_01","S_M_M_NBXRIVERBOATDEALERS_01","S_M_M_NbxRiverBoatGuards_01",
"S_M_M_ORPGUARD_01","S_M_M_PinLaw_01","S_M_M_RACRAILGUARDS_01","S_M_M_RaCRailWorker_01","S_M_M_RHDCOWPOKE_01",
"S_M_M_RHDDEALER_01","S_M_M_SDCOWPOKE_01","S_M_M_SDDEALER_01","S_M_M_SDTICKETSELLER_01","S_M_M_SkpGuard_01","S_M_M_StGSailor_01",
"S_M_M_STRCOWPOKE_01","S_M_M_STRDEALER_01","S_M_M_StrLumberjack_01","S_M_M_Tailor_01","S_M_M_TrainStationWorker_01",
"S_M_M_TumDeputies_01","S_M_M_UNIBUTCHERS_01","S_M_M_UniTrainEngineer_01","S_M_M_UniTrainGuards_01","S_M_M_ValBankGuards_01",
"S_M_M_ValCowpoke_01","S_M_M_VALDEALER_01","S_M_M_VALDEPUTY_01","S_M_M_VHTDEALER_01","S_M_O_CKTWorker_01","S_M_Y_Army_01",
"S_M_Y_NewspaperBoy_01","S_M_Y_RaCRailWorker_01","U_F_M_BHT_WIFE","U_F_M_CIRCUSWAGON_01","U_F_M_EMRDAUGHTER_01",
"U_F_M_FUSSAR1LADY_01","U_F_M_HTLWIFE_01","U_F_M_LagMother_01","U_F_M_NbxResident_01","U_F_M_RhdNudeWoman_01",
"U_F_M_RkSHomesteadTenant_01","U_F_M_STORY_BLACKBELLE_01","U_F_M_STORY_NIGHTFOLK_01","U_F_M_TljBartender_01",
"U_F_M_TumGeneralStoreOwner_01","U_F_M_ValTownfolk_01","U_F_M_ValTownfolk_02","U_F_M_VHTBARTENDER_01",
"U_F_O_Hermit_woman_01","U_F_O_WtCTownfolk_01","U_F_Y_BRAITHWAITESSECRET_01","U_F_Y_CzPHomesteadDaughter_01",
"U_M_M_ANNOUNCER_01","U_M_M_APFDeadMan_01","U_M_M_ARMGENERALSTOREOWNER_01","U_M_M_ARMTRAINSTATIONWORKER_01",
"U_M_M_ARMUNDERTAKER_01","U_M_M_ARMYTRN4_01","U_M_M_AsbGunsmith_01","U_M_M_AsbPrisoner_01","U_M_M_AsbPrisoner_02",
"U_M_M_BHT_BANDITOMINE","U_M_M_BHT_BANDITOSHACK","U_M_M_BHT_BENEDICTALLBRIGHT","U_M_M_BHT_BLACKWATERHUNT",
"U_M_M_BHT_LOVER","U_M_M_BHT_MINEFOREMAN","U_M_M_BHT_NATHANKIRK","U_M_M_BHT_ODRISCOLLDRUNK",
"U_M_M_BHT_ODRISCOLLMAULED","U_M_M_BHT_ODRISCOLLSLEEPING","U_M_M_BHT_OLDMAN","U_M_M_BHT_OUTLAWMAULED",
"U_M_M_BHT_SAINTDENISSALOON","U_M_M_BHT_SHACKESCAPE","U_M_M_BHT_SKINNERBROTHER","U_M_M_BHT_SKINNERSEARCH",
"U_M_M_BHT_STRAWBERRYDUEL","U_M_M_BiVForeman_01","U_M_M_BlWTrainStationWorker_01","U_M_M_BULLETCATCHVOLUNTEER_01",
"U_M_M_BwmStablehand_01","U_M_M_CAJHOMESTEAD_01","U_M_M_CHELONIANJUMPER_01","U_M_M_CHELONIANJUMPER_02",
"U_M_M_CHELONIANJUMPER_03","U_M_M_CHELONIANJUMPER_04","U_M_M_CircusWagon_01","U_M_M_CKTManager_01",
"U_M_M_CORNWALLDRIVER_01","U_M_M_CrDHomesteadTenant_01","U_M_M_CRDHOMESTEADTENANT_02","U_M_M_CRDWITNESS_01",
"U_M_M_CreoleCaptain_01","U_M_M_CzPHomesteadFather_01","U_M_M_DorHomesteadHusband_01","U_M_M_EmRFarmHand_03",
"U_M_M_EmRFather_01","U_M_M_EXECUTIONER_01","U_M_M_FATDUSTER_01","U_M_M_FINALE2_AA_UPPERCLASS_01","U_M_M_GalaStringQuartet_01",
"U_M_M_GalaStringQuartet_02","U_M_M_GalaStringQuartet_03","U_M_M_GalaStringQuartet_04","U_M_M_GAMDoorman_01",
"U_M_M_HHRRANCHER_01","U_M_M_HtlForeman_01","U_M_M_HTLHUSBAND_01","U_M_M_HtlRancherBounty_01","U_M_M_ISLBUM_01",
"U_M_M_LNSOUTLAW_01","U_M_M_LNSOUTLAW_02","U_M_M_lnsoutlaw_03","U_M_M_LNSOUTLAW_04",
"U_M_M_LnSWorker_01","U_M_M_LnSWorker_02","U_M_M_LnSWorker_03","U_M_M_LnSWorker_04",
"U_M_M_LrsHomesteadTenant_01","U_M_M_MFRRANCHER_01","U_M_M_MUD3PIMP_01","U_M_M_NbxBankerBounty_01",
"U_M_M_NbxBartender_01","U_M_M_NbxBartender_02","U_M_M_NbxBoatTicketSeller_01","U_M_M_NbxBronteAsc_01",
"U_M_M_NbxBronteGoon_01","U_M_M_NbxBronteSecForm_01","U_M_M_NbxGeneralStoreOwner_01",
"U_M_M_NBXGraverobber_01","U_M_M_NBXGraverobber_02","U_M_M_NBXGraverobber_03","U_M_M_NBXGraverobber_04",
"U_M_M_NBXGraverobber_05","U_M_M_NbxGunsmith_01","U_M_M_NBXLiveryWorker_01","U_M_M_NbxMusician_01",
"U_M_M_NbxPriest_01","U_M_M_NbxResident_01","U_M_M_NbxResident_02","U_M_M_NbxResident_03",
"U_M_M_NbxResident_04","U_M_M_NBXRIVERBOATPITBOSS_01","U_M_M_NBXRIVERBOATTARGET_01","U_M_M_NBXShadyDealer_01",
"U_M_M_NbxSkiffDriver_01","U_M_M_ODDFELLOWPARTICIPANT_01","U_M_M_ODriscollBrawler_01",
"U_M_M_ORPGUARD_01","U_M_M_RaCForeman_01","U_M_M_RaCQuarterMaster_01","U_M_M_RhdBackupDeputy_01",
"U_M_M_RhdBackupDeputy_02","U_M_M_RhdBartender_01","U_M_M_RHDDOCTOR_01","U_M_M_RhdFiddlePlayer_01",
"U_M_M_RhdGenStoreOwner_01","U_M_M_RhdGenStoreOwner_02","U_M_M_RhdGunsmith_01","U_M_M_RhdPreacher_01",
"U_M_M_RhdSheriff_01","U_M_M_RhdTrainStationWorker_01","U_M_M_RhdUndertaker_01","U_M_M_RIODONKEYRIDER_01",
"U_M_M_RKFRANCHER_01","U_M_M_RKRDONKEYRIDER_01","U_M_M_RWFRANCHER_01","U_M_M_SDBANKGUARD_01",
"U_M_M_SDCUSTOMVENDOR_01","U_M_M_SDEXOTICSSHOPKEEPER_01","U_M_M_SDPHOTOGRAPHER_01","U_M_M_SDPoliceChief_01",
"U_M_M_SDSTRONGWOMANASSISTANT_01","U_M_M_SDTRAPPER_01","U_M_M_SDWEALTHYTRAVELLER_01","U_M_M_SHACKSERIALKILLER_01",
"U_M_M_SHACKTWIN_01","U_M_M_SHACKTWIN_02","U_M_M_SKINNYOLDGUY_01","U_M_M_STORY_ARMADILLO_01","U_M_M_story_CANNIBAL_01",
"U_M_M_STORY_CHELONIAN_01","U_M_M_story_COPPERHEAD_01","U_M_M_story_CREEPER_01","U_M_M_STORY_EMERALDRANCH_01",
"U_M_M_story_HUNTER_01","U_M_M_story_MANZANITA_01","U_M_M_story_MURFEE_01","U_M_M_story_PIGFARM_01",
"U_M_M_story_PRINCESS_01","U_M_M_story_REDHARLOW_01","U_M_M_story_RHODES_01","U_M_M_STORY_SDSTATUE_01",
"U_M_M_story_SPECTRE_01","U_M_M_story_TREASURE_01","U_M_M_STORY_TUMBLEWEED_01","U_M_M_story_VALENTINE_01",
"U_M_M_StrFreightStationOwner_01","U_M_M_StrGenStoreOwner_01","U_M_M_StrSherriff_01","U_M_M_STRWELCOMECENTER_01",
"U_M_M_TumBartender_01","U_M_M_TumButcher_01","U_M_M_TumGunsmith_01","U_M_M_TUMTRAINSTATIONWORKER_01",
"U_M_M_UniBountyHunter_01","U_M_M_UniBountyHunter_02","U_M_M_UNIDUSTERHENCHMAN_01","U_M_M_UNIDUSTERHENCHMAN_02",
"U_M_M_UNIDUSTERHENCHMAN_03","U_M_M_UniDusterLeader_01","U_M_M_UniExConfedsBounty_01","U_M_M_UNIONLEADER_01",
"U_M_M_UNIONLEADER_02","U_M_M_UniPeepingTom_01","U_M_M_ValAuctionForman_01","U_M_M_ValAuctionForman_02",
"U_M_M_ValBarber_01","U_M_M_ValBartender_01","U_M_M_ValBearTrap_01","U_M_M_VALBUTCHER_01","U_M_M_ValDoctor_01",
"U_M_M_ValGenStoreOwner_01","U_M_M_ValGunsmith_01","U_M_M_ValHotelOwner_01","U_M_M_ValPokerPlayer_01",
"U_M_M_ValPokerPlayer_02","U_M_M_ValPoopingMan_01","U_M_M_ValSheriff_01","U_M_M_VALTHEMAN_01",
"U_M_M_ValTownfolk_01","U_M_M_ValTownfolk_02","U_M_M_VhtStationClerk_01","U_M_M_WaLGENERALSTOREOWNER_01",
"U_M_M_WAPOFFICIAL_01","U_M_M_WtCCowboy_04","U_M_O_ARMBARTENDER_01","U_M_O_AsbSheriff_01",
"U_M_O_BHT_DOCWORMWOOD","U_M_O_BlWBartender_01","U_M_O_BlWGeneralStoreOwner_01","U_M_O_BLWPHOTOGRAPHER_01",
"U_M_O_BlWPoliceChief_01","U_M_O_CaJHomestead_01","U_M_O_CMRCIVILWARCOMMANDO_01","U_M_O_MaPWiseOldMan_01",
"U_M_O_OLDCAJUN_01","U_M_O_PSHRancher_01","U_M_O_RigTrainStationWorker_01","U_M_O_ValBartender_01",
"U_M_O_VhTExoticShopkeeper_01","U_M_Y_CajHomeStead_01","U_M_Y_CzPHomesteadSon_01","U_M_Y_CzPHomesteadSon_02",
"U_M_Y_CzPHomesteadSon_03","U_M_Y_CZPHOMESTEADSON_04","U_M_Y_CZPHOMESTEADSON_05","U_M_Y_DuelListBounty_01",
"U_M_Y_EmRSon_01","U_M_Y_HtlWorker_01","U_M_Y_HtlWorker_02","U_M_Y_ShackStarvingKid_01" }
