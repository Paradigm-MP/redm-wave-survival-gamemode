DefaultEvents = class()

function DefaultEvents:__init()
    Events:Subscribe("LocalPlayerSpawn", function() self:LocalPlayerSpawn() end)
    Events:Subscribe("PedSpawned", function(args) self:PedSpawned(args) end)

    Network:Subscribe("DefaultEvents:PlayerDied", function(args) self:PlayerDied(args) end)

    self:StartGameLoop()
end

function DefaultEvents:__postLoad()
    -- Beginning check so we don't get extraneous events
    if LocalPlayer:GetPed():IsDead() then
        LocalPlayer:SetValue("DefaultEvents:Dead", true)
    else
        LocalPlayer:SetValue("DefaultEvents:Dead", false)
    end
end

function DefaultEvents:PedSpawned(args)
    if not args.ped:IsAPlayer() and args.ped:NetworkHasControlOfNetworkId() then
        Network:Send("DefaultEvents:PedSpawned", {ped_net_id = args.ped:GetNetId()})
    end
end

function DefaultEvents:PlayerDied(args)
    Events:Fire("PlayerDied", args)
end

-- Loop to check for various events
function DefaultEvents:StartGameLoop()

    Citizen.CreateThread(function()
        while not LocalPlayer or not LocalPlayer:GetPlayer() do
            Citizen.Wait(100)
        end
        
        -- 10 ms interval
        Citizen.CreateThread(function()
            while true do
                self:CheckLocalPlayer()
                Wait(10)
            end
        end)

        -- 100 ms interval
        Citizen.CreateThread(function()
            while true do
                self:CheckPeds()
                Wait(100)
            end
        end)
    end)

end

-- Check to see if a Ped died. Fires when players die as well.
function DefaultEvents:CheckPeds()
    Citizen.CreateThread(function()
        for net_id, ped in pairs(Peds) do
            local is_dead = ped:IsFatallyInjured() or ped:IsDead()
            
            if is_dead and not ped:GetValue("DefaultEvents:Dead") then
                ped:SetValue("DefaultEvents:Dead", true)

                Events:Fire("PedDied", {
                    ped = ped
                })

                -- If this isn't a player and this client controls the ped, sync the event to the server
                if not ped:IsAPlayer() and ped:NetworkHasControlOfNetworkId() then
                    -- TODO: send more data because the server knows nothing
                    Network:Send("DefaultEvents:PedDied", {
                        ped_net_id = ped:GetNetId()
                    })
                end
            elseif not is_dead and ped:GetValue("DefaultEvents:Dead") then
                -- Ped respawned
                ped:SetValue("DefaultEvents:Dead", false)
                
                Events:Fire("PedRespawned", {
                    ped = ped
                })

                -- If this isn't a player and this client controls the ped, sync the event to the server
                if not ped:IsAPlayer() and ped:NetworkHasControlOfNetworkId() then
                    -- TODO: send more data because the server knows nothing
                    Network:Send("DefaultEvents:PedRespawned", {
                        ped_net_id = ped:GetNetId()
                    })
                end
            end
        end
    end)
end

-- Checks to see if the LocalPlayer died
function DefaultEvents:CheckLocalPlayer()
    if LocalPlayer == nil or LocalPlayer:GetPlayer() == nil then return end

    local ped = LocalPlayer:GetPedId()
    local player = LocalPlayer:GetPlayer():GetId()
    local is_dead = LocalPlayer:GetPed():IsFatallyInjured() or LocalPlayer:GetPed():IsDead()

    if is_dead and not LocalPlayer:GetValue("DefaultEvents:Dead") then
        LocalPlayer:SetValue("DefaultEvents:Dead", true)

        -- From baseevents resource
        local killer, killer_weapon = NetworkGetEntityKillerOfPlayer(player)
        local killer_net_id = PedToNet(killer)
        local killerentitytype = GetEntityType(killer)
        local killer_type = -1
        local killerinvehicle = false
        local killervehiclename = ''
        local killervehicleseat = 0

        if killerentitytype == 1 then
            killer_type = GetPedType(killer)
            if IsPedInAnyVehicle(killer, false) == 1 then
                killerinvehicle = true
                killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(killer)))
                killervehicleseat = GetPedVehicleSeat(killer)
            else 
                killerinvehicle = false
            end
        end

        local death_info = 
        {
            killer_id = killer_net_id,
            killer_type = killer_type, 
            killer_weapon_hash = killer_weapon, 
            killer_in_vehicle = killer_in_vehicle, 
            killer_vehicle_seat = killer_vehicle_seat, 
            killer_vehicle_name = killer_vehicle_name,
            player_pos = LocalPlayer:GetPosition()
        }

        Events:Fire("LocalPlayerDied", death_info)
        Network:Send("DefaultEvents:LocalPlayerDied", death_info)
    end
end

function DefaultEvents:LocalPlayerSpawn()
    LocalPlayer:SetValue("DefaultEvents:Dead", false)
end

DefaultEvents = DefaultEvents()