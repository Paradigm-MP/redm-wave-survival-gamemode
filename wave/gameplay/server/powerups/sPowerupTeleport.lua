PowerupTeleport = class()

function PowerupTeleport:__init()
    self.max_charges = shGameplayConfig.PowerupData[PowerupTypesEnum.Teleport].maxCharges
    self.duration = shGameplayConfig.PowerupData[PowerupTypesEnum.Teleport].duration
    self.instance = nil
    
    Network:Subscribe("gameplay/powerups/UseTeleport", function(args)
        self:UseTeleport(args) end)
end

function PowerupTeleport:UseTeleport(args)
    local charges = args.player:GetValue("TeleportCharges")
    if not charges or charges == 0 then return end
    if not args.position then return end
    if not args.player:GetValue("Alive") or args.player:GetValue("Downed") then return end

    args.player:SetValue("TeleportCharges", charges - 1)
    Network:Broadcast("gameplay/powerups/UseTeleport", {
        id = args.player:GetUniqueId(),
        position = args.position,
        old_position = args.old_position
    })

    if charges == 0 then
        self:ResetPlayer(args.player)
    end
end

function PowerupTeleport:Activate(args)
    -- Serverside function for when someone gets the powerup
    self:ResetPlayer(args.player)
    args.player:SetValue("TeleportCharges", self.max_charges)
    args.player:SetValue("TeleportId", args.id)
end

function PowerupTeleport:ResetPlayer(player)
    player:SetValue("TeleportCharges", 0)
end

function PowerupTeleport:Deactivate(args)
    if args.player and args.player:GetValue("TeleportId") == args.id then
        self:ResetPlayer(args.player)
    end
end