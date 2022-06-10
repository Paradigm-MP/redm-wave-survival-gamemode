ArmorLocalPlayerBehavior = class()
ArmorLocalPlayerBehavior.name = "ArmorLocalPlayerBehavior"

function ArmorLocalPlayerBehavior:__init()
    Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)
end

function ArmorLocalPlayerBehavior:PlayerNetworkValueChanged(args)
    if not LocalPlayer:IsPlayer(args.player) then return end
    
    if args.name == "Armor" and shGameplayConfig.ArmorData[args.val] then
        local resistance = shGameplayConfig.ArmorData[args.val].resistance
        if not resistance then return end

        SetAiMeleeWeaponDamageModifier(resistance)
        SetAiWeaponDamageModifier(resistance)

        -- If they purchased a better armor, play the purchase sound
        if args.old_val ~= nil and args.val > args.old_val then
            GamePlayUI:GetUI():CallEvent('gameplayui/purchase/sfx')
        end

        local percent_complete = (args.val / 5)

        if args.val == 0 then
            -- Remove powerup UI, if it exists
            GamePlayUI:ModifyPowerup({
                type = "armor",
                charges = 0
            })
        elseif args.val == 1 then
            -- add powerup UI
            GamePlayUI:AddPowerup({
                type = "armor",
                progress = percent_complete
            })
        else
            -- modify powerup UI to add more armor
            GamePlayUI:ModifyPowerup({
                type = "armor",
                progress = percent_complete
            })
        end
    end

end