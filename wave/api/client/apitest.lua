ApiTest = class()

function ApiTest:__init()
    RegisterCommand('yeet', function(source, args, rawCommand)
        local me = Ped({ped = GetPlayerPed(PlayerId())})

        Weapons:GiveWeaponStr(GetPlayerPed(PlayerId()), "weapon_" .. args[1], 999, true)

    end)

    RegisterCommand('yeetr', function(source, args, rawCommand)
        local me = Ped({ped = GetPlayerPed(PlayerId())})

        Weapons:RemovePedWeapon(GetPlayerPed(PlayerId()), "weapon_PumpShotgun")

    end)

    RegisterCommand('yeetd', function(source, args, rawCommand)
        -- local me = Ped({ped = GetPlayerPed(PlayerId())})

        Weapons:SetPlayerWeaponDamage(Player:GetId(), args[1].toFloat())

    end)

    RegisterCommand('makeped', function(source, args, rawCommand)
        local notme = Ped({
            pedType = PedTypes.PED_TYPE_COP,
            modelName = "a_m_m_afriamer_01",
            pos = LocalPlayer:GetPosition(),
            heading = 0,
            isNetwork = true,
            thisScriptCheck = true
        })
    end)

    Citizen.CreateThread(function()
        while true do
        N_0x4757f00bc6323cfe(GetHashKey("WEAPON_UNARMED"), 0.99) 
        Wait(0)
        end
    end)

    -- me:SetPosition(me:GetPosition() + vector3(0, 2, 0))
    -- me:SetAlpha(200, false)
    -- me:ResetAlpha()

    -- RequestScriptAudioBank('dlc_testing/testing', 0)

    --[[local notme = Ped({
        pedType = PedTypes.PED_TYPE_COP,
        modelName = "a_m_m_afriamer_01",
        pos = me:GetPosition(),
        heading = 0,
        isNetwork = true,
        thisScriptCheck = true
    })--]]

    RegisterCommand('light', function(source, args, rawCommand)

        -- PlaySoundFrontend(-1, 'Testing_Spawn', 'DLC_TESTING_SOUNDS', 1)
        local me = Ped({ped = GetPlayerPed(PlayerId())})

        -- PlaySoundFrontend(-1, 'Testing_Spawn', 'DLC_TESTING_SOUNDS', 1)
        local me = Ped({ped = GetPlayerPed(PlayerId())})

        local light = Light({
            position = me:GetPosition() + vector3(0, 0, 0.5),
            type = LightTypes.Point,
            color = Color(0, 0, 0),
            range = 500,
            intensity = 500,
            shadow = false
        })

        CreateThread(function()
            while true do
                light:SetPosition(me:GetPosition())
                Wait(0)
            end
        end)

    end)

    -- me:ToggleCollision(true)
    -- SetPedGadget(me:GetEntity(), GetHashKey("GADGET_PARACHUTE"), true)
    -- GiveWeaponToPed(me:GetEntity(), GetHashKey("GADGET_PARACHUTE"), 1, true, true)
    -- me:SetToRagdoll(5000)
    -- me:SetVelocity(vector3(0,0,1000))
    -- local obj = Object({position = me:GetPosition() + vector3(0,2,0), model = 'prop_gate_airport_01', kinematic = true})
    RegisterCommand('obj', function(source, args, rawCommand)
        local me = Ped({ped = GetPlayerPed(PlayerId())})
        local obj = Object({
            position = me:GetPosition() + vector3(0, 0, 0),
            model = args[1],
            kinematic = true,
            callback = function(obj)
                print("hello! obj model is " .. tostring(obj:GetModel()))
            end
        })

    end)

    function debugtext(text)
        Render:DrawText(vector2(0.1, 0.1), tostring(text), Colors.White, 1, 0)
    end

    Events:Subscribe("Render", function()

        -- local pos = me:GetPosition()
        -- local ray = Physics:Raycast(pos, Camera:GetPosition() + Camera:GetRotation() * 1000, 1, me.ped)
        -- Render:DrawLine(pos, ray.position, Colors.LawnGreen)
        -- Render:DrawSphere(me:GetBonePosition(0), 1, Colors.Red)
        -- Render:DrawBox(me:GetPosition(), me:GetPosition() + vector3(1,2,1), Color(255,0,0,0.5))
        -- local pos = me:GetVelocity()
        -- debugtext(string.format("x: %.2f, y: %.2f, z: %.2f", pos.x, pos.y, pos.z))
        -- obj:SetQuaternion(me:GetQuaternion())
        -- debugtext(me:IsJumping())

    end)
end
