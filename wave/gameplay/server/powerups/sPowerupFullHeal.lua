PowerupFullHeal = class()

function PowerupFullHeal:__init()

end

function PowerupFullHeal:Activate(args)
    -- Serverside function for getting downed players up
    for id, player in pairs(GameManager:GetPlayers()) do
        if player:GetValue("Spawned") and player:GetValue("Alive") then
            player:SetNetworkValue("Downed", false)
        end
    end
end

function PowerupFullHeal:Deactivate()
end