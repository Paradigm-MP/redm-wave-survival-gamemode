PowerupLightningStrike = class()

function PowerupLightningStrike:__init()
    self.max_charges = shGameplayConfig.PowerupData[PowerupTypesEnum.LightningStrike].maxCharges
    self.duration = shGameplayConfig.PowerupData[PowerupTypesEnum.LightningStrike].duration
    self.instance = nil
    
    Network:Subscribe("gameplay/powerups/UseLightningStrike", function(args)
        self:UseLightningStrike(args) end)
end

function PowerupLightningStrike:UseLightningStrike(args)
    local charges = args.player:GetValue("LightningStrikeCharges")
    if not charges or charges == 0 then return end
    if not args.position then return end
    if not args.player:GetValue("Alive") or args.player:GetValue("Downed") then return end

    args.player:SetValue("LightningStrikeCharges", charges - 1)
    Network:Broadcast("gameplay/powerups/UseLightningStrike", {
        id = args.player:GetUniqueId(),
        position = args.position
    })

    if charges == 0 then
        self:ResetPlayer(args.player)
    end
end

function PowerupLightningStrike:Activate(args)
    -- Serverside function for when someone gets the powerup
    self:ResetPlayer(args.player)
    args.player:SetValue("LightningStrikeCharges", self.max_charges)
    args.player:SetValue("LightningStrikeId", args.id)
end

function PowerupLightningStrike:ResetPlayer(player)
    player:SetValue("LightningStrikeCharges", 0)
end

function PowerupLightningStrike:Deactivate(args)
    if args.player and args.player:GetValue("LightningStrikeId") == args.id then
        self:ResetPlayer(args.player)
    end
end