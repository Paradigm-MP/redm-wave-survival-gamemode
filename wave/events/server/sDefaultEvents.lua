DefaultEvents = class()

function DefaultEvents:__init()

    Network:Subscribe("DefaultEvents:LocalPlayerDied", function(args) self:PlayerDied(args) end)
    Network:Subscribe("DefaultEvents:PedDied", function(args) self:PedDied(args) end)
    Network:Subscribe("DefaultEvents:PedSpawned", function(args) self:PedSpawned(args) end)
    Network:Subscribe("DefaultEvents:PedRespawned", function(args) self:PedRespawned(args) end)
end

function DefaultEvents:PedDied(args)
    assert(type(args.ped_net_id) == "number" and args.ped_net_id > -1, "DefaultEvents:PedRespawned failed, ped_net_id invalid")
    Events:Fire("PedDied", args)
end

function DefaultEvents:PedSpawned(args)
    assert(type(args.ped_net_id) == "number" and args.ped_net_id > -1, "DefaultEvents:PedRespawned failed, ped_net_id invalid")
    Events:Fire("PedSpawned", args)
end

function DefaultEvents:PedRespawned(args)
    assert(type(args.ped_net_id) == "number" and args.ped_net_id > -1, "DefaultEvents:PedRespawned failed, ped_net_id invalid")
    Events:Fire("PedRespawned", args)
end

--[[
    Only sent by the player who died.
]]
function DefaultEvents:PlayerDied(args)
    Events:Fire("PlayerDied", args)
    args.id = args.player:GetId()
    args.player_unique_id = args.player:GetUniqueId()
    args.player = nil
    Network:Broadcast("DefaultEvents:PlayerDied", args)
end

DefaultEvents = DefaultEvents()