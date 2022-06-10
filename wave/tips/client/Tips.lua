Tips = class()

function Tips:__init()
    self.ui = UI:Create({
        name = "tips", 
        path = "tips/client/html/index.html",
        css = {
            ["width"] = "450px",
            ["height"] = "250px",
            ["top"] = "25vh",
            ["position"] = "fixed",
            ["right"] = "0"
        }
    })

    self.time_between_tips = 1000 * 60 * 1 -- Every 1 minutes

    self.lobby_index = 1
    self.ingame_index = 1

    self.tips = 
    {
        Lobby = 
        {
            "Select a map, then hit \"Join\" and \"Ready\" to play a game!",
            "If a game is already in progress, hit \"Join Game\" to join it!",
            "On this server, you survive against waves of enemies.",
            "This is a cooperative minigame, so invite your friends and team up!",
            "Press T to open the chat, and Enter to send a message.",
            "Don't like the way you look? You can buy and equip skins at the shop.",
            "All money earned ingame goes towards your shop money.",
            "Wondering what features latest update had? Check out the UPDATES tab.",
        },
        Ingame = 
        {
            "Enemies incoming! Watch out for them; they can come from anywhere.",
            "When you kill enemies, you get money. You can buy weapons and other things with money.",
            "Weapon spawns are hidden around the map. Try looking for them!",
            "Once you find a weapon spawn, you can use your money to purchase the weapon.",
            "The game gets more difficult as the rounds progress, so make sure to buy new weapons!",
            "If a teammate goes down, you can revive them by holding E when standing on them.",
            "Feel free to explore the map! There are great places to hide and shoot enemies.",
            "By exploring the map, you can also find more weapon spawns.",
            "Weapon spawns are randomized every game, so you\'ll have to explore every time.",
            "Sometimes when you kill an enemy, they will drop a random powerup.",
            "Powerups are temporary effects that help you, such as Double Money or DeadShot.",
            "Looking for ammo? Buy the gun again or get a Max Ammo powerup.",
            "As the game progresses, things get more difficult! You can upgrade armor at a hidden location."
        }
    }

    Citizen.CreateThread(function()
        Citizen.Wait(1000 * 5)
        self:Loop()
    end)
end

function Tips:Loop()
    Citizen.CreateThread(function()

        -- Check if they have played for at least an hour, if so then disable tips
        local time_online = LocalPlayer:GetPlayer():GetValue("TimeOnline")
        if time_online and time_online > 60 then
            return
        end

        self.ui:BringToFront()
        local in_lobby = LobbyManager:GetUI():GetVisible()
        if in_lobby then
            self.ui:CallEvent('tips/add', 
                {title = "Tip", description = self.tips.Lobby[self.lobby_index]})
            self.lobby_index = self.lobby_index + 1
            if self.lobby_index > #self.tips.Lobby then self.lobby_index = 1 end
        else
            self.ui:CallEvent('tips/add', 
                {title = "Tip", description = self.tips.Ingame[self.ingame_index]})
            self.ingame_index = self.ingame_index + 1
            if self.ingame_index > #self.tips.Ingame then self.ingame_index = 1 end
        end

        Citizen.Wait(self.time_between_tips)
        self:Loop()
    end)
end

Tips = Tips()